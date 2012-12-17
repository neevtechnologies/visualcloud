class InstanceType < ActiveRecord::Base
  # attr_accessible :title, :body
  attr_accessible :name, :size, :api_name ,:resource_type_id, :description, :label

  has_many :instances
  belongs_to :resource_type
  #Returns an array of arrays containing ec2 instance name and id
  def self.get_select_collection(type)
    @instances = ResourceType.find_by_name(type).instance_types
    @instances.collect{|ec_ins| [ec_ins.name, ec_ins.id]}
  end
end
