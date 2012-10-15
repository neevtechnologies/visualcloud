class Instance < ActiveRecord::Base
  attr_accessible :aws_instance_id, :label, :size, :url, :xpos, :ypos, :ami_id

  belongs_to :graph
  belongs_to :resource_type

  validates :label , presence: true, uniqueness: true
  validates :xpos , numericality: true
  validates :ypos , numericality: true
end
