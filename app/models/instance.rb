class Instance < ActiveRecord::Base
  include AwsCompatibleName
  include InstanceRole
  attr_accessible :aws_instance_id, :label, :aws_label, :size, :url, :xpos, :ypos,
                  :instance_type_id, :config_attributes, :instance_status

  attr_encrypted :config_attributes, :key => VisualCloudConfig[:attr_encryption_salt]

  belongs_to :environment
  belongs_to :resource_type
  belongs_to :instance_type
  #belongs_to :ami

  has_many     :parent_child_relationships,
               :class_name            => "InstanceRelationship",
               :foreign_key           => :child_id,
               :dependent             => :destroy
  has_many     :parents,
               :through               => :parent_child_relationships,
               :source                => :parent

  has_many     :child_parent_relationships,
               :class_name            => "InstanceRelationship",
               :foreign_key           => :parent_id,
               :dependent             => :destroy
  has_many     :children,
               :through               => :child_parent_relationships,
               :source                => :child

  validates :label , presence: true, uniqueness: { scope: :environment_id }
  validates :xpos , numericality: true
  validates :ypos , numericality: true

  before_create :set_aws_compatible_name
  after_destroy :modify_node_data

  # Applies roles to instance
  # Returns true after instance roles got set
  def apply_roles(roles = nil)
    if roles.nil?
      attributes = JSON.parse(self.config_attributes)
      roles = attributes['roles']
    end
    logger.info("Applying roles #{roles.inspect} to instance : #{id}: #{label}")
    return add_role(id, roles)
  end

  # Gets the ami corresponding to instance if present
  def ami
    attributes = JSON.parse(config_attributes)
    Ami.find(attributes['ami_id']) rescue nil
  end

  # Updates the instance config attributes after provisioned successfully
  def update_output(environment_output, instance_output)
    existing_config_attributes = JSON.parse(config_attributes)
    if ec2?
      add_elastic_ip(environment_output, instance_output)
    end
    merged_attributes = existing_config_attributes.merge(instance_output).to_json
    update_attribute(:config_attributes, merged_attributes )
    update_attribute(:instance_status, "running")
  end

  #returns true if the ec2 instance status is stopped and we passed start as parameter else false
  #returns false if the environment is not yet provisioned
  def check_status_of_ec2_element(status)
    return_value = false
    if self.environment.provision_status == "CREATE_COMPLETE" || self.environment.provision_status == "UPDATE_COMPLETE"
      return_value = (self.instance_status == status) ? false : true
    end
    return return_value
  end

  #returns true if the ec2 instance status is running else false
  def wait_till_started(access_key_id, secret_access_key, sleep_interval = VisualCloudConfig[:status_check_interval])
    logger.info("Waiting till ec2 instance is running : instance: #{self.aws_label}")
    status = self.get_instance_status(access_key_id, secret_access_key)
    while(status == 'pending')
      sleep sleep_interval
      status = self.get_instance_status(access_key_id, secret_access_key)
    end
    return_value = (status == 'running') ? true : false
    return return_value
  end

  #returns true if the ec2 instance status is stopped else false
  def wait_till_stopped(access_key_id, secret_access_key, sleep_interval = VisualCloudConfig[:status_check_interval])
    logger.info("Waiting till ec2 instance is stopped : instance: #{self.aws_label}")
    status = self.get_instance_status(access_key_id, secret_access_key)
    while(status == 'stopping')
      sleep sleep_interval
      status = self.get_instance_status(access_key_id, secret_access_key)
    end
    return_value = (status == 'stopped') ? true : false
    return return_value
  end

  #fetches the instance status of a specific instance given by the aws_label from the cloud
  def get_instance_status(access_key_id, secret_access_key)
    cloud = Cloudster::Cloud.new(access_key_id: access_key_id, secret_access_key: secret_access_key)
    ec2_instances = cloud.get_ec2_details(stack_name: self.environment.aws_name)
    status = ""
    ec2_instances.each do |key, value|
      if key == self.aws_label
        status = value['instanceState']['name']
        break
      end
    end
    self.update_attribute("instance_status", status) if status != nil
    return status rescue nil
  end

  #updates the existing config attributes with framed new config attributes based on the task i.e start or stop
  #updates the instance_status with framed new config attributes based on the task i.e start or stop
  def update_status_and_config_attributes(task, access_key_id, secret_access_key)
    new_config_attributes = get_new_config_attributes(task, access_key_id, secret_access_key)
    existing_config_attributes = JSON.parse(config_attributes)
    merged_attributes = existing_config_attributes.merge(new_config_attributes).to_json
    status = task == "start" ? "running" : "stopped"
    update_attribute(:instance_status, status)
    update_attribute(:config_attributes, merged_attributes )
  end

  #returns the framed new config attributes based on the task i.e start or stop
  def get_new_config_attributes(task, access_key_id, secret_access_key)
    cloud = Cloudster::Cloud.new(access_key_id: access_key_id, secret_access_key: secret_access_key)
    ec2_instances = cloud.get_ec2_details(stack_name: self.environment.aws_name)
    new_config_attributes = {}
    unless ec2_instances.blank?
      ec2_instances.each do |key, value|
        if self.aws_label == key
          if task == "stop"
            new_config_attributes = {"private_ip" => "", "public_ip" => "", "private_dns_name" => "", "public_dns_name" => ""}
          else
            new_config_attributes = {"private_ip" => value["privateIpAddress"],"public_ip" => value["ipAddress"],"private_dns_name" => value["privateDnsName"],"public_dns_name" => value["dnsName"]}
          end
        end
      end
    end
    return new_config_attributes
  end

  #starts the specific ec2 instance by considering its physical id as input
  def start_ec2_instance(access_key_id, secret_access_key)
    ec2 = Fog::Compute::AWS.new(:aws_access_key_id => access_key_id, :aws_secret_access_key => secret_access_key, :region => self.environment.region.name)
    config_attributes = JSON.parse(self.config_attributes)
    update_attribute(:instance_status, "pending")
    ec2.start_instances(config_attributes['instance_id'])
  end

  #stops the specific ec2 instance by considering its physical id as input
  def stop_ec2_instance(access_key_id, secret_access_key)
    ec2 = Fog::Compute::AWS.new(:aws_access_key_id => access_key_id, :aws_secret_access_key => secret_access_key, :region => self.environment.region.name)
    config_attributes = JSON.parse(self.config_attributes)
    update_attribute(:instance_status, "stopping")
    ec2.stop_instances(config_attributes['instance_id'])
  end


  private

  # Deletes the specific item node object and the its client
  # Deletes the specific item object details from the data bag of nodes
  def modify_node_data
    logger.info "INFO: Started deleting node and client for Instance with id #{self.id}"
    DeleteNodeWorker.perform_async(self.id)
    logger.info "INFO: Finished deleting node and client for Instance with id #{self.id}"
    logger.info "INFO: Started deleting data bag entry for node #{self.id}"
    DeleteDataBagWorker.perform_async({data_bag_name: "nodes", item_id: self.id})
    logger.info "INFO: Finished deleting data bag entry for node #{self.id}"
  end

  # Checks the instance belongs to ec2 type or not
  def ec2?
    self.resource_type.resource_class == 'EC2'
  end

  # Updates the elastic ip field of the instance after successful provision if elastic ip attribute present
  def add_elastic_ip(environment_output, instance_output)
    unless environment_output["ElasticIp#{aws_label}"].nil?
      instance_output.merge!(environment_output["ElasticIp#{aws_label}"])
    end
  end

  # Sets aws compatible name for the given instance name
  def set_aws_compatible_name
    self.aws_label = aws_compatible_name(self.label)
  end

end
