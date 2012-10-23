class InstanceRelationship < ActiveRecord::Base
  belongs_to :parent, :class_name => "Instance"
  belongs_to :child, :class_name => "Instance"
end
