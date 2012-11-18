class Project < ActiveRecord::Base
  # attr_accessible :title, :body
  attr_accessible :name, :description, :repo_type, :repo_url, :frame_work, :managed, :user_id ,:environments_attributes
  has_and_belongs_to_many :users
  validates_uniqueness_of :name, :scope => 'user_id'
  has_many :environments, :dependent => :destroy
  accepts_nested_attributes_for :environments
end
