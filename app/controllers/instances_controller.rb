class InstancesController < ApplicationController
  before_filter :authenticate

  #starts individual ec2 instance if it is in stopped state
  def start_ec2_instance
    @instance = Instance.find(params[:id])
    @errors = []
    if current_user.aws_access_key.nil? || current_user.aws_secret_key.nil?
      @errors << "You have not added your AWS access key"
      flash.now[:error] = @errors
    else
      if @errors.blank? && @instance.check_status_of_ec2_element("running")
        flash[:success] = "Start request of ec2 instance initiated"
        StartEc2InstancesWorker.perform_async(access_key_id: current_user.aws_access_key,
          secret_access_key: current_user.aws_secret_key,
          instance_id: @instance.id
        )
      else
        if @instance.environment.provision_status == nil
          @errors << "Environment is not yet provisioned"
        else
          @errors << "Ec2 instance is already started"
        end
        flash.now[:error] = @errors
      end
    end
  end

  #stops individual ec2 instance if it is in running state
  def stop_ec2_instance
    @instance = Instance.find(params[:id])
    @errors = []
    if current_user.aws_access_key.nil? || current_user.aws_secret_key.nil?
      @errors << "You have not added your AWS access key"
      flash.now[:error] = @errors
    else
      if @errors.blank? && @instance.check_status_of_ec2_element("stopped")
        flash[:success] = "Stop request of ec2 instance initiated"
        StopEc2InstancesWorker.perform_async(access_key_id: current_user.aws_access_key,
          secret_access_key: current_user.aws_secret_key,
          instance_id: @instance.id
        )
      else
        if @instance.environment.provision_status == nil
          @errors << "Environment is not yet provisioned"
        else
          @errors << "Ec2 instance is already stopped"
        end
        flash.now[:error] = @errors
      end
    end
  end
end
