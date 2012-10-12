class InstancesController < ApplicationController
  before_filter :authenticate_user!

  def create_ec2
    @resource_type = ResourceType.where(name: 'EC2').first
    create_instance
  end

  def create_rds
    @resource_type = ResourceType.where(name: 'RDS').first
    create_instance
  end

  private

    def create_instance
      @instance = Instance.new(params[:instance])
      unless @instance.save
        flash.now[:error] = @instance.errors.full_messages
      else
        flash.now[:success] = "Instance added successfully"
      end
    rescue Exception => e
      logger.error("Error occured while saving instance : #{e.inspect}")
      flash.now[:error] = "An error occured while saving the instance"
    end
end
