class ResourceType < ActiveRecord::Base
  attr_accessible :ami_id, :large_icon, :name, :small_icon
end
