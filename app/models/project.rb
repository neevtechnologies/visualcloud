class Project < ActiveRecord::Base
  # attr_accessible :title, :body
  attr_accessible :name, :description, :repo_type, :repo_url, :frame_work, :managed, :user_id ,:environments_attributes
  has_and_belongs_to_many :users
  validates_uniqueness_of :name, :scope => 'user_id'
  has_many :environments, :dependent => :destroy
  accepts_nested_attributes_for :environments
  
  after_destroy :modify_project_data
  
  private 
 
  def modify_project_data
    logger.info "INFO: Started deleting data bag entry for Project #{self.id}"
    DeleteDataBagWorker.perform_async({data_bag_name: "projects", item_id: self.id})
    logger.info "INFO: Finished deleting data bag entry for Project #{self.id}"
  end  
end
