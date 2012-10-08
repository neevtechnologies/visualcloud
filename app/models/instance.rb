class Instance < ActiveRecord::Base
  attr_accessible :aws_instance_id, :label, :size, :url, :xpos, :ypos
end
