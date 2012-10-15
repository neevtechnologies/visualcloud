class Graph < ActiveRecord::Base
  attr_accessible :name

  has_many :instances

  validates :name, presence: true
end
