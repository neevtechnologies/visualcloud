class Deploy < ActiveRecord::Base
  # attr_accessible :title, :body
    attr_accessible :revision, :status, :environment_id
    belongs_to :environment
end
