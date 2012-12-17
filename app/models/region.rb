class Region < ActiveRecord::Base
  attr_accessible :name, :latitude, :longitude, :display_name
  has_many :environments

 def self.region_list
   results = [];
   self.all.each do |r|
     results <<  { latLng: [r.latitude,r.longitude], name: r.name, display_name: r.display_name, id: r.id }
   end
  results.to_json
 end

end
