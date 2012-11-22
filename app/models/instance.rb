class Instance < ActiveRecord::Base
  include InstanceRole
  attr_accessible :aws_instance_id, :label, :size, :url, :xpos, :ypos, :ami_id,
                  :instance_type_id, :config_attributes, :public_dns, :private_ip, :aws_instance_id

  belongs_to :environment
  belongs_to :resource_type
  belongs_to :instance_type
  belongs_to :ami

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
  
  validates :label , presence: true
  validates :xpos , numericality: true
  validates :ypos , numericality: true

  def apply_roles(roles = nil)
    if roles.nil?
      attributes = JSON.parse(self.config_attributes)
      roles = attributes['roles']
    end
    logger.info("Applying roles #{roles.inspect} to instance : #{id}: #{label}")
    return add_role(id, roles)
  end

end
