class InstanceType < ActiveRecord::Base
  # attr_accessible :title, :body
  attr_accessible :name, :size, :api_name

  has_many :instances
  belongs_to :resource_type
  #Returns an array of arrays containing ec2 instance name and id
  def self.get_select_collection
    all.collect{|ec_ins| [ec_ins.name, ec_ins.id]}
  end
end
