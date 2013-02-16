class EnvironmentsController < ApplicationController
  include ServerMetaData
  include AwsCompatibleName
  before_filter :authenticate
  before_filter :authorize, :except => [:get_key_pairs_and_security_groups]
  require "csv"

  # GET /environments/new
  # GET /environments/new.json
  # TODO : Code Review : duplciate block in new and edit. refactor it
  def new
    @project = Project.find(params[:project_id])
    #TODO: Can this be removed ? Are we showing environments list in new page
    @environments = @project.environments
    @environment = Environment.new(params[:environment])
    @resource_types = RESOURCE_TYPES
    @ec2_instance_types = ResourceType.find_by_name('EC2').instance_types
    @rds_instance_types = ResourceType.find_by_name('RDS').instance_types
    @elasticache_instance_types = ResourceType.find_by_name('ElastiCache').instance_types
    @key_pairs, @security_groups = current_user.get_key_pair_and_security_groups

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @environment }
    end
  end

  # GET /environments/1/edit
  def edit
    @environments = @project.environments
    @environment = Environment.find(params[:id])
    @resource_types = RESOURCE_TYPES
    @ec2_instance_types = ResourceType.find_by_name('EC2').instance_types
    @rds_instance_types = ResourceType.find_by_name('RDS').instance_types
    @elasticache_instance_types = ResourceType.find_by_name('ElastiCache').instance_types
    @key_pairs, @security_groups = current_user.get_key_pair_and_security_groups
  end

  def export_csv
    @environment = Environment.find(params[:id])
    @project = Project.find(@environment.project_id)
    @instances = @environment.instances
    csv_string = CSV.generate do |csv|
      # Project details
      csv << ["Id", "Project Name"]
      csv << [@project.id, @project.name]
      # Environment details
      csv << ["Id", "Environment Name","Key Pair Name", "Security Group", "Name in AWS Console","Region"]
      csv << [@environment.id, @environment.name,@environment.key_pair_name, @environment.security_group, @environment.aws_name,@environment.region.name]
      # Instances details
      csv << ["Id", "Instance Label", "Instance Type","Resource Type", "Config Attributes", "Name in AWS Console"]
      @instances.each do |instance|
        instance_type = instance.instance_type_id.present? ? instance.instance_type.name : ""
        csv << [instance.id, instance.label,instance_type , instance.resource_type.name, instance.config_attributes, instance.aws_label]
      end
    end

    # send csv file(users.csv) to browser
    send_data(csv_string, :type => 'text/csv; charset=utf-8; header=present', :filename => "environment_details.csv")
  end

  # POST /environments
  def create
    errors = []
    @project = Project.find(params[:project_id])
    @environment = Environment.new(params[:environment])
    logger.info "Environment: #{@environment.inspect}"
    @environment.project = @project
    if !@environment.save
      errors << "Environment has the following errors :"
      errors += @environment.errors.full_messages
    end

    saved_doms = {}
    # TODO : Code Review :  use a transaction for multiple  dmls
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
  #  TODO : Code Review : do object level access check for view/edit/delete/update
  def update
    @project = Project.find(params[:project_id])
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

  # DELETE /environments/1
  # DELETE /environments/1.json
  def destroy
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
    @instance_ids = {}
    @errors = []
    update_instances
    if current_user.aws_access_key.nil? || current_user.aws_secret_key.nil?
      @errors << "You have not added your AWS access key"
      flash.now[:error] = @errors
    else
      if @errors.blank? && @environment.provision(current_user.aws_access_key, current_user.aws_secret_key)
        flash[:success] = "Provision request initiated"
        RoleAssignmentWorker.perform_async(access_key_id: current_user.aws_access_key,
          secret_access_key: current_user.aws_secret_key,
          environment_id: @environment.id
        )
        @environment.instances.each{|instance| @instance_ids[instance.label] = instance.id }
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

  # Get the status of environment and output params of instances
  def status
    environment = Environment.find(params[:id])
    status_code = environment.provision_status
    status_hash = {
      status: status_code,
      instanceAttributes: {}
    }
    environment.instances.each do |instance|
      status_hash[:instanceAttributes][instance.id] = JSON.parse(instance.config_attributes)
    end
    render json: status_hash.to_json
  end

  # Fetch Key Pair and security group based on region
  def get_key_pairs_and_security_groups
    unless params[:region].blank?
      key_pairs, security_groups = current_user.get_key_pair_and_security_groups(params[:region])
      @key_pairs = key_pairs.collect {|kp| kp["keyName"]}.to_json
      @security_groups = security_groups.collect {|sg| sg["groupName"]}.to_json
      respond_to do |format|
        format.js
      end
    else
      render nothing: true
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
      #Think about x, y positions
      @environment.instances.destroy_all

      saved_doms = {}
      params[:instances].to_a.each do |instance|
        #TODO This logic is obscure . Need to refactor this
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
          end
        end
      end
      @environment.reload
      save_connections(saved_doms)
    end

    #Project should belong to the user
    def authorize
      if params[:id].present?
        @environment = Environment.find(params[:id])
        @project = Project.find_by_user_id_and_id(current_user.id,@environment.project_id) rescue nil
      else
        @project = Project.find_by_user_id_and_id(current_user.id,params[:project_id]) rescue nil
      end
      raise CanCan::AccessDenied, "Nothing to see here, move on" if @project.nil? || params[:project_id] != @project.id.to_s
    end

end
