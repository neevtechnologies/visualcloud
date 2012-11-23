module ServerMetaData
  include JsonFormatter  

  def update_node_data_bag(obj)
    begin
      file = File.open("/tmp/nodes.json","w+") 
      file.puts nodes_json(obj)
      file.close
      system("knife data bag from file nodes /tmp/nodes.json")
    rescue => e
      puts "Error modifying Databag nodes for #{obj.id}! #{e.inspect}"
    ensure
      File.delete(file)
    end
  end

  def update_project_data_bag(obj, options={})
    begin
      file = File.open("/tmp/projects.json","w+") 
      file.puts projects_json(obj, options)
      file.close
      system("knife data bag from file projects /tmp/projects.json")
    rescue => e
      puts "Error modifying Databag projects for #{obj.id}! #{e.inspect}"
      puts e.backtrace
    ensure
      File.delete(file)
    end
  end

  def delete_data_bag_item(data_bag_name, obj_id)
    begin
      system("knife data bag delete #{data_bag_name} #{obj_id} -y")
    rescue => e
      puts "Error deleting Databag #{data_bag_name} for #{obj_id}! #{e.inspect}"
      puts e.backtrace
    end
  end

end
