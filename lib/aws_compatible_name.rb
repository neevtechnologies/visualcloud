module AwsCompatibleName
 
 def aws_compatible_name(name)
   name.to_s.gsub(/[^[a-zA-Z0-9]]/,"") + Time.now.utc.to_i.to_s unless name.blank?
 end

end
