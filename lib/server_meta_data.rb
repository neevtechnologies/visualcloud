module ServerMetaData
  include JsonFormatter  
  def modify_data_bag bag_name, obj
    begin
      # Create a temporary json file
      file = File.open("/tmp/#{bag_name}.json","w+") 
      (bag_name == "projects") ? (file.puts projects_json obj) : (file.puts nodes_json obj)
      file.close
      # Create or update a data bag content
      system("knife data bag from file #{bag_name} /tmp/#{bag_name}.json")
    rescue => e
      puts "Error modifying Databag #{bag_name} for #{obj.id}! #{e.inspect}"
    ensure
      # Ensure deletion of temporary file
      File.delete(file)
    end
  end
end
