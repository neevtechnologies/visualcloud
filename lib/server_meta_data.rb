module ServerMetaData
  include JsonFormatter  

  def update_node_data_bag(obj)
    begin
      # Create a temporary json file
      file = File.open("/tmp/nodes.json","w+") 
      file.puts nodes_json(obj)
      file.close
      # Create or update a data bag content
      system("knife data bag from file nodes /tmp/nodes.json")
    rescue => e
      puts "Error modifying Databag nodes for #{obj.id}! #{e.inspect}"
    ensure
      # Ensure deletion of temporary file
      File.delete(file)
    end
  end

  def update_project_data_bag(obj, options={})
    begin
      # Create a temporary json file
      file = File.open("/tmp/projects.json","w+") 
      file.puts projects_json(obj, options)
      file.close
      # Create or update a data bag content
      system("knife data bag from file projects /tmp/projects.json")
    rescue => e
      puts "Error modifying Databag projects for #{obj.id}! #{e.inspect}"
      puts e.backtrace
    ensure
      # Ensure deletion of temporary file
      File.delete(file)
    end
  end
end
