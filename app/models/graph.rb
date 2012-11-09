require 'cloudster'
class Graph < ActiveRecord::Base
  attr_accessible :name, :project_id

  has_many :instances, :dependent => :destroy
  belongs_to :project
  validates :name, presence: true

  def provision(access_key_id, secret_access_key)
    stack_resources = []

    instance_names = add_ec2_resources(stack_resources)
    add_elb_resource(stack_resources, instance_names)
    add_rds_resources(stack_resources)

    cloud = Cloudster::Cloud.new(access_key_id: access_key_id, secret_access_key: secret_access_key)

    if self.provisioned
      provision_request = cloud.update(resources: stack_resources, stack_name: name, description: 'Provisioned by VisualCloud')
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
    cloud = Cloudster::Cloud.new(access_key_id: access_key_id, secret_access_key: secret_access_key)
    status = cloud.events(stack_name: name)
  end

  def add_ec2_resources(stack_resources)
    instance_names = []
    instances.each do |instance|
      if instance.resource_type.name == 'EC2'
        stack_resources << Cloudster::Ec2.new(name: instance.label, 
                                              key_name: 'default', 
                                              image_id: instance.ami.image_id,
                                              instance_type: instance.instance_type.api_name )
        instance_names << instance.label
      end
    end
    return instance_names
  end

  def add_elb_resource(stack_resources, instance_names)
    instances.each do |instance|
      if instance.resource_type.name == 'ELB'
        stack_resources << Cloudster::Elb.new(name: instance.label, instance_names: instance_names )
      end
    end
  end

  def add_rds_resources(stack_resources)
    instances.each do |instance|
      if instance.resource_type.name == 'RDS'
        config_attributes = JSON.parse(instance.config_attributes)
        puts config_attributes.inspect
        stack_resources << Cloudster::Rds.new(name: instance.label, 
                                              instance_class: instance.instance_type.api_name, 
                                              storage_size: config_attributes['size'],
                                              username: config_attributes['master_user_name'],
                                              password: config_attributes['master_password']
                                             )
      end
    end
  end

  def delete_stack(access_key_id, secret_access_key)
    cloud = Cloudster::Cloud.new(access_key_id: access_key_id, secret_access_key: secret_access_key)
    cloud.delete(stack_name: name)
    return true
  rescue => e
    puts e.inspect
    puts e.backtrace
    return false
  end

end
