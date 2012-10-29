require 'cloudster'
class Graph < ActiveRecord::Base
  attr_accessible :name

  has_many :instances

  validates :name, presence: true

  def provision(access_key_id, secret_access_key)
    stack_resources = []
    instances.each do |instance|
      resource_type = instance.resource_type.name
      case resource_type
      when 'EC2'
        stack_resources << Cloudster::Ec2.new(name: instance.label, 
                                              key_name: 'default', 
                                              image_id: instance.ami.image_id,
                                              instance_type: instance.instance_type.api_name )
      when 'ELB'
        # Add elb resource
      when 'S3'
        # Add S3 resource
      else
        # Default resource
      end
    end
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
    return false
  end

  def status(access_key_id, secret_access_key)
    cloud = Cloudster::Cloud.new(access_key_id: access_key_id, secret_access_key: secret_access_key)
    status = cloud.events(stack_name: name)
  end

end
