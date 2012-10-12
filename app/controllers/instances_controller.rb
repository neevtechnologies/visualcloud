class InstancesController < ApplicationController
  before_filter :authenticate_user!

  def create_ec2
    @resource_type = ResourceType.where(name: 'EC2').first
    @instance = Instance.new(params[:instance])        
    unless @instance.save
      flash.now[:error] = @instance.errors.full_messages
    else
      flash.now[:success] = "EC2 Instance saved successfully"
    end
  rescue Exception => e
    logger.error("Error occured while saving EC2 instance : #{e.inspect}")
    flash.now[:error] = "An error occured while creating instance of EC2"
  end

  def create_rds
    @resource_type = ResourceType.where(name: 'RDS').first
    @instance = Instance.new(params[:instance])
    unless @instance.save
      flash.now[:error] = @instance.errors.full_messages
    else
      flash.now[:success] = "RDS Instance saved successfully"
    end
  rescue Exception => e
    flash.now[:error] = "An error occured while creating instance of RDS"
  end
end
