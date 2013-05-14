class StartEc2InstancesWorker
  include Sidekiq::Worker
  #Do not retry failed jobs for now. Can be changed later.
  sidekiq_options retry: false


  #starts all ec2 instances if passes environment id as argument
  #starts individual ec2 instance if passes instance id as argument
  #after getting all ec2 instances started it updates the config attributes and the instance status
  def perform(options)    
    options.symbolize_keys!
    if options[:environment_id].present?
      environment = Environment.find(options[:environment_id])
      environment.start_ec2_instances(options[:access_key_id], options[:secret_access_key])
      provision_status = environment.wait_till_started(options[:access_key_id], options[:secret_access_key])
    else
      instance = Instance.find(options[:instance_id])
      environment = instance.environment
      instance.start_ec2_instance(options[:access_key_id], options[:secret_access_key])
      provision_status = instance.wait_till_started(options[:access_key_id], options[:secret_access_key])
    end
    if provision_status
      if options[:environment_id].present?
        environment.update_ec2_instances_config_attributes("start", options[:access_key_id], options[:secret_access_key])
      else
        instance.update_status_and_config_attributes("start",options[:access_key_id], options[:secret_access_key])
      end
      environment.set_meta_data(options[:access_key_id], options[:secret_access_key])
    end
  end
end
