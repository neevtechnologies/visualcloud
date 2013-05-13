class Environment < ActiveRecord::Base
  include ServerMetaData
  include AwsCompatibleName
  attr_accessible :name, :aws_name, :project_id, :key_pair_name, :security_group, :region_id

  has_many :instances, :dependent => :destroy
  belongs_to :project
  belongs_to :region
  validates :name, presence: true

  before_create :set_aws_compatible_name
  before_destroy :modify_environment_data

  # provisioning the environment
  # return true if it is successfully provisioned
  # returns false in case of any failure while provisioning
  def provision(access_key_id, secret_access_key)
    return true if access_key_id == 'demo'
    stack_resources = []

    instance_names = add_ec2_resources(stack_resources)
    add_elb_resource(stack_resources, instance_names)
    add_rds_resources(stack_resources)
    add_s3_resources(stack_resources)
    add_elasticache_resources(stack_resources)

    cloud = Cloudster::Cloud.new(access_key_id: access_key_id, secret_access_key: secret_access_key, region: region_name)

    #provision_status will hold the actual stack status
    if self.provision_status == nil
      cloud.provision(resources: stack_resources, stack_name: aws_name, description: 'Provisioned by VisualCloud')
      self.provisioned = true
      self.save
    else
      cloud.update(resources: stack_resources, stack_name: aws_name, description: 'Updated by VisualCloud')
    end
    return true
  rescue Exception => e
    logger.error "Error while provisioning environment: #{self.name}: #{e.inspect}"
    return false
  end

  # Returns the status of the given environment
  def status(access_key_id, secret_access_key)
    if access_key_id.present? && secret_access_key.present?
      cloud = Cloudster::Cloud.new(access_key_id: access_key_id, secret_access_key: secret_access_key)
      return cloud.status(stack_name: aws_name)
    else
      return nil
    end
  end

  #Returns all RDS(database) endpoints in a stack
  def get_rds_endpoints(access_key_id, secret_access_key)
    cloud = Cloudster::Cloud.new(access_key_id: access_key_id, secret_access_key: secret_access_key)
    cloud.get_database_endpoints(stack_name: aws_name)
  end

  #Returns all the stack related events for the AWS account.
  #Returns events related to all the stacks with the given name.
  def events(access_key_id, secret_access_key)
    cloud = Cloudster::Cloud.new(access_key_id: access_key_id, secret_access_key: secret_access_key)
    return cloud.events(stack_name: aws_name)
  end

  #Collects all the ec2 type elements of the environment into stack_resources array
  #Returns collection of ec2 type resource names
  #If elastic ip option provided, adds an ElasticIp to an ec2 type instance
  def add_ec2_resources(stack_resources)
    instance_names = []
    key_pair = self.key_pair_name.blank? ? 'default' : self.key_pair_name
    security_groups = (self.security_group.to_s.strip.split(/\s*,\s*/).blank? ? ['default'] : self.security_group.to_s.strip.split(/\s*,\s*/))
    instances.each do |instance|
      if instance.resource_type.resource_class == 'EC2'
        ec2 = Cloudster::Ec2.new(name: instance.aws_label,
          key_name: key_pair,
          security_groups: security_groups,
          image_id: instance.ami.image(region_name),
          instance_type: instance.instance_type.api_name )
        chef_client = Cloudster::ChefClient.new(
          validation_key: File.read(VisualCloudConfig[:validation_key_path]),
          server_url: VisualCloudConfig[:chef_server_url],
          node_name: instance.id.to_s,
          interval: VisualCloudConfig[:chef_client_interval],
          validation_client_name: VisualCloudConfig[:chef_validation_client_name]
        )
        chef_client.add_to ec2
        config_attributes = JSON.parse(instance.config_attributes)
        if config_attributes["elasticIp"]
          elastic_ip = Cloudster::ElasticIp.new(:name => "ElasticIp#{instance.aws_label}")
          elastic_ip.add_to ec2
        end
        stack_resources << ec2
        instance_names << instance.aws_label
      end
    end
    return instance_names
  end

  #Adds elb resource with ec2 resource names in it, to stack_resources array
  def add_elb_resource(stack_resources, instance_names)
    instances.each do |instance|
      if instance.resource_type.resource_class == 'ELB'
        # Choose the children EC2 instances, which have been created successfully.
        instance_names = (instance_names & instance.children.collect(&:aws_label))
        stack_resources << Cloudster::Elb.new(
          name: instance.aws_label,
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

  #Adds rds resources to stack_resources array
  def add_rds_resources(stack_resources)
    instances.each do |instance|
      if instance.resource_type.resource_class == 'RDS'
        config_attributes = JSON.parse(instance.config_attributes)
        stack_resources << Cloudster::Rds.new(name: instance.aws_label,
          instance_class: instance.instance_type.api_name,
          storage_size: config_attributes['size'],
          username: config_attributes['master_user_name'],
          password: config_attributes['master_password'],
          multi_az: config_attributes['multiAZ']
        )
      end
    end
  end

  #Adds s3 resources to stack_resources array
  def add_s3_resources(stack_resources)
    instances.each do |instance|
      if instance.resource_type.resource_class == 'S3'
        config_attributes = JSON.parse(instance.config_attributes)
        s3 = Cloudster::S3.new(name: instance.aws_label, access_control: config_attributes["access_control"])
        if config_attributes["cloudFront"]
          cloud_front = Cloudster::CloudFront.new(:name => "CloudFront#{instance.aws_label}")
          cloud_front.add_to(s3)
        end
        stack_resources << s3
      end
    end
  end

  #Adds elasticache resources to stack_resources array
  def add_elasticache_resources(stack_resources)
    instances.each do |instance|
      if instance.resource_type.resource_class == 'ElastiCache'
        config_attributes = JSON.parse(instance.config_attributes)
        stack_resources << Cloudster::ElastiCache.new(
          :name => instance.aws_label,
          :node_type => instance.instance_type.api_name,
          :cache_security_group_names => config_attributes['cache_security_group_names'],
          :engine => 'memcached', #Only memcached is supported by AWS right now
          :node_count => config_attributes['node_count']
        )
      end
    end
  end

  #Deletes stack and the attached resources
  def delete_stack(access_key_id, secret_access_key)
    return true if access_key_id == 'demo'
    logger.info "INFO: Calling cloudster to delete environment #{self.name}"
    cloud = Cloudster::Cloud.new(access_key_id: access_key_id, secret_access_key: secret_access_key)
    cloud.delete(stack_name: self.aws_name)
    logger.info "INFO: Deleted environment #{self.name}"
    return true
  rescue => e
    logger.error "Error while deleting environment: #{self.name}"
    return false
  end

  #Setting Meta Data in DataBags before assigning roles for instances in environment
  #check for the database role is present for instances present in the environment
  #Updates the data bags of nodes for instances and projects for environment
  def set_meta_data(access_key_id, secret_access_key)
    logger.info("Setting Meta Data in DataBags before assigning roles for instances in environment : #{self.aws_name}")
    db_instance_present = false
    options = {}
    instances.each do |instance|
      update_node_data_bag(instance) if instance.resource_type.resource_class == 'EC2'
    end
    if has_rds?
      logger.info("Environment : #{self.aws_name} has an RDS resource")
      db_instance_present = true
      endpoints = get_rds_endpoints(access_key_id, secret_access_key)
      db_ip_addr = endpoints[0][:address] unless endpoints.blank?
      logger.info("Found RDS instance with IP : #{db_ip_addr} for environment : #{self.aws_name}")
      options.merge!({:rds_ip_address => db_ip_addr})
    else
      instances.each do |instance|
        config_attributes = JSON.parse(instance.config_attributes)
        instance_roles = config_attributes['roles'] || []
        if instance_roles.include?('db')
          logger.info("Applying roles: #{instance_roles.inspect} to db instance : #{instance.id} for environment : #{self.aws_name}")
          instance.apply_roles(instance_roles)
          db_instance_present = true
        end
      end
    end
    options.merge!({:db_instance_present => db_instance_present})
    logger.info("Setting : #{options.inspect} to databag of environment : #{self.aws_name}")
    update_project_data_bag(self.project, { self.id => options })
  end

  #Sets roles for each instance element
  def set_roles
    instances.each do |instance|
      instance.apply_roles
    end
  end

  #Check for rds resource element in the instances
  def has_rds?
    instances.each do |instance|
      return true if instance.resource_type.resource_class == "RDS"
    end
    return false
  end

  #Waits till the provision process is completed
  # for demo case it will not contact aws api's
  def wait_till_provisioned(access_key_id, secret_access_key, sleep_interval = VisualCloudConfig[:status_check_interval])
    logger.info("Waiting till stack is provisioned : environment: #{self.aws_name}")
    update_attribute(:provision_status, "CREATE_IN_PROGRESS")
    if access_key_id == 'demo'
      stack_status = 'CREATE_COMPLETE'
    else
      stack_status = self.status(access_key_id, secret_access_key)
    end
    while ( (stack_status == 'CREATE_IN_PROGRESS') || (stack_status.blank?) )
      logger.info("Stack status = #{stack_status}")
      sleep sleep_interval
      stack_status = self.status(access_key_id, secret_access_key)
    end
    if stack_status == 'CREATE_COMPLETE'
      logger.info("Environment #{self.aws_name} was provisioned successfully.")
      update_attribute(:provision_status, stack_status)
      return true
    else
      logger.error("Environment #{self.aws_name} was not provisioned: status - #{stack_status}")
      update_attribute(:provision_status, stack_status)
      return false
    end
  end

  #Updating all instances of the environment with the output values,
  # after the stack provision process gets completed
  def update_instance_outputs(access_key_id, secret_access_key)
    return if access_key_id == 'demo'
    cloud = Cloudster::Cloud.new(access_key_id: access_key_id, secret_access_key: secret_access_key)
    outputs = cloud.outputs(stack_name: aws_name)
    outputs.each do |key, value|
      instances.where(aws_label: key).each do |instance|
        instance.update_output(key, value)
      end
    end
  end

  private

  # Updates the projects data bag when deleting the environment belongs to a project item
  def modify_environment_data
    logger.info "INFO: Started updating project data bag to delete the environment #{self.id} entry"
    UpdateProjectDataBagWorker.perform_async(self.project)
    logger.info "INFO: Finished updating project data bag to delete the environment #{self.id} entry"
  end

  # Sets aws compatible name for the given environment name
  def set_aws_compatible_name
    self.aws_name = aws_compatible_name(self.name)
  end

  # Returns the region name
  def region_name
    region.name
  end
end
