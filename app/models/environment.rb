require 'cloudster'
class Environment < ActiveRecord::Base
  include ServerMetaData
  attr_accessible :name, :branch, :db_migrate, :deploy_order, :project_id, :key_pair_name, :security_group

  has_many :instances, :dependent => :destroy
  belongs_to :project
  has_many :deployments, :dependent => :destroy
  validates :name, presence: true
  validates_uniqueness_of :deploy_order, :scope => 'project_id' , :allow_blank => true
  
  after_destroy :modify_environment_data
  
  #TODO: This should go , whatever it's doing.
  def self.get_select_collection(id)    
    (1..Project.find(id).environments.count).to_a.collect { |v| v.to_i }
  end

  def provision(access_key_id, secret_access_key)
    stack_resources = []

    instance_names = add_ec2_resources(stack_resources)
    add_elb_resource(stack_resources, instance_names)
    add_rds_resources(stack_resources)

    cloud = Cloudster::Cloud.new(access_key_id: access_key_id, secret_access_key: secret_access_key)

    if self.provisioned
      provision_request = cloud.update(resources: stack_resources, stack_name: name, description: 'Updated by VisualCloud')
    else
      provision_request = cloud.provision(resources: stack_resources, stack_name: name, description: 'Provisioned by VisualCloud')
      self.provisioned = true
      self.save
    end
    return true
  rescue Exception => e
    puts e.inspect
    puts e.backtrace
    return false
  end

  def status(access_key_id, secret_access_key)
    if access_key_id.present? && secret_access_key.present?
      cloud = Cloudster::Cloud.new(access_key_id: access_key_id, secret_access_key: secret_access_key)
      return cloud.status(stack_name: name)
    else
      return nil
    end
  end

  def get_rds_endpoints(access_key_id, secret_access_key)
    cloud = Cloudster::Cloud.new(access_key_id: access_key_id, secret_access_key: secret_access_key)
    cloud.get_database_endpoints(stack_name: name)
  end

  def events(access_key_id, secret_access_key)
    cloud = Cloudster::Cloud.new(access_key_id: access_key_id, secret_access_key: secret_access_key)
    return cloud.events(stack_name: name)
  end

  def add_ec2_resources(stack_resources)
    instance_names = []
    key_pair = self.key_pair_name.blank? ? 'ec2-access' : self.key_pair_name
    security_groups = (self.security_group.to_s.strip.split(/\s*,\s*/).blank? ? nil : self.security_group.to_s.strip.split(/\s*,\s*/))
    instances.each do |instance|
      if instance.resource_type.resource_class == 'EC2'
        ec2 = Cloudster::Ec2.new(name: instance.label,
          key_name: key_pair,
          security_groups: security_groups,
          image_id: instance.ami.image_id,
          instance_type: instance.instance_type.api_name )
        chef_client = Cloudster::ChefClient.new(
          validation_key: File.read(VisualCloudConfig[:validation_key_path]),
          server_url: VisualCloudConfig[:chef_server_url],
          node_name: instance.id.to_s,
          interval: VisualCloudConfig[:chef_client_interval]
        )
        chef_client.add_to ec2
        stack_resources << ec2
        instance_names << instance.label
      end
    end
    return instance_names
  end

  def add_elb_resource(stack_resources, instance_names)
    instances.each do |instance|
      if instance.resource_type.resource_class == 'ELB'
        # Choose the children EC2 instances, which have been created succesfully.
        instance_names = (instance_names & instance.children.collect(&:label))
        stack_resources << Cloudster::Elb.new(
          name: instance.label,
          instance_names: instance_names,
          listeners: [
            {
              port: VisualCloudConfig[:webserver_port],
              instance_port: VisualCloudConfig[:application_port],
              protocol: VisualCloudConfig[:load_balancer_protocol]
            }
          ]
        )
      end
    end
  end

  def add_rds_resources(stack_resources)
    instances.each do |instance|
      if instance.resource_type.resource_class == 'RDS'
        config_attributes = JSON.parse(instance.config_attributes)
        stack_resources << Cloudster::Rds.new(name: instance.label, 
          instance_class: instance.instance_type.api_name, 
          storage_size: config_attributes['size'],
          username: config_attributes['master_user_name'],
          password: config_attributes['master_password'],
          multi_az: config_attributes['multiAZ']
        )
      end
    end
  end

  def delete_stack(access_key_id, secret_access_key)
    logger.info "INFO: Calling cloudster to delete stack #{self.name}"
    puts "INFO: Calling cloudster to delete stack #{self.name}"
    cloud = Cloudster::Cloud.new(access_key_id: access_key_id, secret_access_key: secret_access_key)
    cloud.delete(stack_name: self.name)
    logger.info "INFO: Deleted stack #{self.name}"
    puts "INFO: Deleted stack #{self.name}"
    return true
  rescue => e
    puts e.inspect
    puts e.backtrace
    return false
  end

  def update_instances(access_key_id, secret_access_key)
    cloud = Cloudster::Cloud.new(access_key_id: access_key_id, secret_access_key: secret_access_key)
    logger.info "INFO: Updating the ec2 instance details for stack #{self.name}"
    ec2_details = cloud.get_ec2_details(stack_name: self.name)
    logger.info "INFO: EC2 details for stack #{name} : #{ec2_details.inspect}"
    while ec2_details.nil?
      sleep VisualCloudConfig[:status_check_interval]
      ec2_details = cloud.get_ec2_details(stack_name: self.name)
    end
    instances.where('label in (?)', ec2_details.keys).each do |instance|
      instance_details = ec2_details[instance.label]
      if instance_details.present?
        instance.update_attributes({
            aws_instance_id: instance_details['instanceId'],
            public_dns: instance_details['dnsName'],
            private_ip: instance_details['ipAddress']
          })
      end
    end
    logger.info "INFO: Updated the ec2 instance details for stack #{self.name}"
  end

  def set_meta_data(access_key_id, secret_access_key)
    logger.info("Setting Meta Data in DataBags before assigning roles for instances in environment : #{name}")
    db_instance_present = false
    options = {}
    instances.each do |instance|
      update_node_data_bag(instance) if instance.resource_type.resource_class == 'EC2'
    end
    if has_rds?
      logger.info("Environment : #{name} has an RDS resource")
      db_instance_present = true
      endpoints = get_rds_endpoints(access_key_id, secret_access_key)
      db_ip_addr = endpoints[0][:address] unless endpoints.blank?
      logger.info("Found RDS instance with IP : #{db_ip_addr} for environment : #{name}")
      options.merge!({:rds_ip_address => db_ip_addr})
    else
      db_instance = nil
      instances.each do |instance|
        config_attributes = JSON.parse(instance.config_attributes)
        instance_roles = config_attributes['roles']
        if instance_roles.include?('db')
          logger.info("Applying roles: #{instance_roles.inspect} to db instance : #{instance.id} for environment : #{name}")
          instance.apply_roles(instance_roles)
          db_instance_present = true
        end
      end
    end
    options.merge!({:db_instance_present => db_instance_present})
    logger.info("Setting : #{options.inspect} to databag of environment : #{name}")
    update_project_data_bag(self.project, { self.id => options })
  end

  def set_roles
    instances.each do |instance|
      instance.apply_roles
    end
  end

  def has_rds?
    instances.each do |instance| 
      return true if instance.resource_type.resource_class == "RDS"
    end
    return false
  end

  def wait_till_provisioned(access_key_id, secret_access_key, sleep_interval = VisualCloudConfig[:status_check_interval])
    logger.info("Waiting till stack is provisioned : environment: #{name}")
    stack_status = self.status(access_key_id, secret_access_key)
    while ( (stack_status == 'CREATE_IN_PROGRESS') || (stack_status.blank?) )
      logger.info("Stack status = #{stack_status}")
      sleep sleep_interval
      stack_status = self.status(access_key_id, secret_access_key)
    end
    if stack_status == 'CREATE_COMPLETE'
      logger.info("Environment #{name} was provisioned successfully.")
      return true
    else
      logger.error("Environment #{name} was not provisioned.")
      return false
    end
  end
 
  private

  def modify_environment_data
    logger.info "INFO: Started updating project data bag to delete the environment #{self.id} entry"
    UpdateProjectDataBagWorker.perform_async(self.project)
    logger.info "INFO: Finished updating project data bag to delete the environment #{self.id} entry"
  end

end
