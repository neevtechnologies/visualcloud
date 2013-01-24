class ResourceType < ActiveRecord::Base
  attr_accessible :ami_id, :name, :small_icon, :resource_class, :description, :parents_list, :roles

  has_many :instances
  has_many :instance_types
end
