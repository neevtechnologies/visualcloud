class Ami < ActiveRecord::Base
  attr_accessible :architecture, :description, :image_id, :name

  #Returns an array of arrays containing ami description and id
  def self.get_select_collection
    all.collect{|ami| [ami.description, ami.id]}
  end

end
