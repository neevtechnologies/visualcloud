class InstancesController < ApplicationController
  before_filter :authenticate_user!

  def create_ec2
    @instance = Instance.new(params[:instance])
    @resource_type = ResourceType.where(name: 'EC2').first
    unless @instance.save
      flash.now[:error] = @instance.errors.full_messages
    else
      flash.now[:success] = "Instance saved successfully"
    end
  rescue Exception => e
    logger.error("Error occured while saving EC2 instance : #{e.inspect}")
    flash.now[:error] = "An error occured while creating instance"
  end

end
