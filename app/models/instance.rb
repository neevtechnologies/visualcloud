class Instance < ActiveRecord::Base
  attr_accessible :aws_instance_id, :label, :size, :url, :xpos, :ypos, :ami_id
  validates :label , uniqueness: true
  validates :xpos , numericality: true
  validates :ypos , numericality: true
end
