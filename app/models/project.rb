class Project < ActiveRecord::Base
  # attr_accessible :title, :body
  attr_accessible :name, :description, :repo_type, :repo_url, :repo_auth ,:user_id
  has_and_belongs_to_many :users
  validates_uniqueness_of :name, :scope => 'user_id'
  has_many :graphs, :dependent => :destroy
end
