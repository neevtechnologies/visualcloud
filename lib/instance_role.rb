module InstanceRole

  #Adds roles to the specific node(instance) object in the data bag of nodes
  def add_role(instance_id, roles)
    role_list = []
    return true if roles.blank?
    roles.each do |role|
      role_list << "role[#{role}]"
    end
    retry_count = 0

    until system("knife node run_list add #{instance_id} \"#{role_list.join(',')}\"")
      #return false if retry_count == 5
      sleep 5
      retry_count += 1
    end
    return true
  end
end
