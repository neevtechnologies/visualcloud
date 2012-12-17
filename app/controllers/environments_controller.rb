class EnvironmentsController < ApplicationController
  include ServerMetaData
  include AwsCompatibleName 
  before_filter :authenticate
  # GET /environments
  # GET /environments.json
  def index
    @environments = Environment.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @environments }
    end
  end

  # GET /environments/1
  # GET /environments/1.json
  def show
    @environment = Environment.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @environment }
    end
  end

  # GET /environments/new
  # GET /environments/new.json
  def new
    @project = Project.find(params[:project_id])
    @environments = @project.environments
    @environment = Environment.new
    @resource_types = RESOURCE_TYPES
    @ec2_instance_types = ResourceType.find_by_name('EC2').instance_types
    @rds_instance_types = ResourceType.find_by_name('RDS').instance_types
    @key_pairs, @security_groups = current_user.get_key_pair_and_security_groups

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @environment }
    end
  end

  # GET /environments/1/edit
  def edit
    @project = Project.find(params[:project_id])
    @environments = @project.environments
    @environment = Environment.find(params[:id])
    @resource_types = RESOURCE_TYPES
    @ec2_instance_types = ResourceType.find_by_name('EC2').instance_types
    @rds_instance_types = ResourceType.find_by_name('RDS').instance_types
    @key_pairs, @security_groups = current_user.get_key_pair_and_security_groups
  end

  # POST /environments
  def create
    errors = []
    @project = Project.find(params[:project_id])
    @environment = Environment.new(params[:environment])
    @environment.project = @project
    if !@environment.save
      errors << "Environment has the following errors :"
      errors += @environment.errors.full_messages
    end

    saved_doms = {}
    params[:instances].to_a.each do |instance|
      if instance.length > 2 #delete instance has length 2
        resouce_type_name = instance.delete(:resource_type)
        dom_id = instance.delete(:dom_id)
        parent_dom_ids = instance.delete(:parent_dom_ids)
        config_attributes = instance.delete(:config_attributes).to_json
        resource_type = ResourceType.where(name: resouce_type_name).first
        instance = Instance.new(instance)
        instance.config_attributes = config_attributes
        instance.environment = @environment
        instance.resource_type = resource_type
        if !instance.save
          errors << "#{instance.label} has the following error(s) :"
          errors += instance.errors.full_messages
        else
          saved_doms[dom_id] = { instance: instance, parent_dom_ids: parent_dom_ids }
          #update_node_data_bag(instance)
        end
      end
    end

    save_connections(saved_doms)

    if errors.blank?
      flash[:success] = "Environment saved successfully."
    else
      flash.now[:error] = errors
    end

  rescue Exception => e
    logger.error("Error occured while saving the environment : #{e.inspect}")
    flash.now[:error] = "Error occured while saving the Environment."
    errors << "Error occured while saving the Environment"
  ensure
    respond_to do |format|
      format.js
    end
  end

  # PUT /environments/1
  def update
    @project = Project.find(params[:project_id])
    @environment = Environment.find(params[:id])
    @errors = []
    update_instances

    if @errors.blank?
      flash.now[:success] = "Environment updated successfully."
    else
      flash.now[:error] = @errors
    end

    respond_to do |format|
      format.js
    end
  end

  def update_environment
    @environment = Environment.find(params[:id])
    @errors = []    
    if @environment.update_attributes(params[:environment])
      flash.now[:success] = "Environment fields updated successfully."
    else
      @errors << "Environment fields could not be updated successfully."
      flash.now[:error] = @errors
    end

    respond_to do |format|
      format.js
    end
  end

  # DELETE /environments/1
  # DELETE /environments/1.json
  def destroy
    @project = Project.find(params[:project_id])
    @environment = Environment.find(params[:id])
    if current_user.aws_access_key.nil? || current_user.aws_secret_key.nil?
      flash[:error] = "You have not added your AWS access key"
    else
      if @environment.delete_stack(current_user.aws_access_key, current_user.aws_secret_key)
        if @environment.destroy
          flash[:success] = "Environment deleted successfully."
        else
          flash[:error] = "An error occured while trying to delete environment."
        end
      else
        flash[:error] = "An error occured while trying to delete environment."
      end
    end
    respond_to do |format|
      format.html { redirect_to project_url(@project) }
      format.json { head :no_content }
    end
  end

  # Provisions the stack
  def provision
    @environment = Environment.find(params[:id])
    @environment.update_attributes(params[:environment])
    @errors = []
    update_instances
    if current_user.aws_access_key.nil? || current_user.aws_secret_key.nil?
      @errors << "You have not added your AWS access key"
      flash.now[:error] = @errors
    else
      if @environment.provision(current_user.aws_access_key, current_user.aws_secret_key)
        flash.now[:success] = "Provision request initiated"
        RoleAssignmentWorker.perform_async(access_key_id: current_user.aws_access_key,
          secret_access_key: current_user.aws_secret_key,
          environment_id: @environment.id
        ) 
      else
        @errors << "This environment cannot be provisioned"
        flash.now[:error] = @errors
      end
    end
  end
  
  # Get the status of the Environment from DB
  def environment_status
    unless params[:id].blank?
      @environment = Environment.find(params[:id])
      @status = @environment.provision_status
      respond_to do |format|
        format.js
      end
    else
      render :nothing => true
    end
  end

  # Get the original status of the Stack from Amazon
  def stack_status
    unless params[:id].blank?
      @environment = Environment.find(params[:id])
      @status = @environment.status(current_user.aws_access_key, current_user.aws_secret_key)
      @environment.update_column("provision_status", @status)
      respond_to do |format|
        format.js
      end
    else
      render :nothing => true
    end
  end


  private
    
  def save_connections(saved_doms)
    return if saved_doms.empty?
    saved_doms.each do |dom_id , instance|
      record = instance[:instance]
      parents = []
      instance[:parent_dom_ids].to_a.each do |parent_dom_id|
        parents << saved_doms[parent_dom_id][:instance]
      end
      record.parents = parents
      record.save!
    end
  end

  def update_instances
    #Remove all instances and start with a clean slate. It's not easy to track edited instances
    @environment.instances.destroy_all

    saved_doms = {}
    params[:instances].to_a.each do |instance|
      if instance.length > 2 #delete instance has length 2
        resouce_type_name = instance.delete(:resource_type)
        dom_id = instance.delete(:dom_id)
        parent_dom_ids = instance.delete(:parent_dom_ids)
        config_attributes = instance.delete(:config_attributes).to_json
        resource_type = ResourceType.where(name: resouce_type_name).first
        instance = Instance.new(instance)
        instance.config_attributes = config_attributes
        instance.environment = @environment
        instance.resource_type = resource_type
        if !instance.save
          @errors << "#{instance.label} has the following error(s) :"
          @errors += instance.errors.full_messages
        else
          saved_doms[dom_id] = { instance: instance, parent_dom_ids: parent_dom_ids }
          #update_node_data_bag(instance)
        end
      end
    end
    @environment.reload
    save_connections(saved_doms)
  end

end
