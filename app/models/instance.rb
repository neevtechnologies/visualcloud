class Instance < ActiveRecord::Base
  include AwsCompatibleName
  include InstanceRole
  attr_accessible :aws_instance_id, :label, :aws_label, :size, :url, :xpos, :ypos,
                  :instance_type_id, :config_attributes, :aws_instance_id

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
  
  validates :label , presence: true, uniqueness: { scope: :environment_id }
  validates :xpos , numericality: true
  validates :ypos , numericality: true
  
  before_save :set_aws_compatible_name
  after_destroy :modify_node_data
  
  def apply_roles(roles = nil)
    if roles.nil?
      attributes = JSON.parse(self.config_attributes)
      roles = attributes['roles']
    end
    logger.info("Applying roles #{roles.inspect} to instance : #{id}: #{label}")
    return add_role(id, roles)
  end

  def ami
    attributes = JSON.parse(config_attributes)
    Ami.find(attributes['ami_id']) rescue nil
  end

  def update_output(environment_output, instance_output)
    existing_config_attributes = JSON.parse(config_attributes)
    if ec2?
      add_elastic_ip(environment_output, instance_output)
    end
    merged_attributes = existing_config_attributes.merge(instance_output).to_json
    update_attribute(:config_attributes, merged_attributes )
  end

  private

    def modify_node_data
      logger.info "INFO: Started deleting node and client for Instance with id #{self.id}"
      DeleteNodeWorker.perform_async(self.id)
      logger.info "INFO: Finished deleting node and client for Instance with id #{self.id}"
      logger.info "INFO: Started deleting data bag entry for node #{self.id}"
      DeleteDataBagWorker.perform_async({data_bag_name: "nodes", item_id: self.id})
      logger.info "INFO: Finished deleting data bag entry for node #{self.id}"
    end

    def ec2?
      self.resource_type.resource_class == 'EC2'
    end

    def add_elastic_ip(environment_output, instance_output)
      unless environment_output["ElasticIp#{aws_label}"].nil?
        instance_output.merge!(environment_output["ElasticIp#{aws_label}"])
      end
    end

    def set_aws_compatible_name
       self.aws_label = aws_compatible_name(self.label)
    end
end
