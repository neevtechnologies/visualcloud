class RoleAssignmentWorker
  include Sidekiq::Worker
  #Do not retry failed jobs for now. Can be changed later.
  sidekiq_options retry: false


  #Set databag item "master_db_address"
  ##If RDS, keep on polling for Address.
  ##If no RDS ,
  #If address available , continue
  #Run role of App Instances, recipe should increment data bag item by 1 for "app_servers_deployed"
  #If number of app_servers_deployed = Number of app instances , continue
  #Run role of LoadBalancer
  def perform(options)
    options.symbolize_keys!
    environment = Environment.find(options[:environment_id])
    provision_status = environment.wait_till_provisioned(options[:access_key_id], options[:secret_access_key])
    if provision_status
      environment.set_meta_data(options[:access_key_id], options[:secret_access_key])
      environment.update_instance_outputs(options[:access_key_id], options[:secret_access_key])
      environment.set_roles
    end

  end
end
