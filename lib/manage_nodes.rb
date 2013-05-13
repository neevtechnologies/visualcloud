module ManageNodes
 #Deletes the client of the specific object
 def delete_client(client)
  begin
    system("knife client delete #{client} -y") if client.present? && client.to_i != 0
  rescue => e
    puts "ERROR: Exception deleting client #{client}"
    puts e.backtrace
  end
 end

 #Deletes the node of the specific object
 def delete_node(node)
  begin
    system("knife node delete #{node} -y") if node.present? && node.to_i != 0
  rescue => e
    puts "ERROR: Exception deleting node #{node}"
    puts e.backtrace
  end
 end
end
