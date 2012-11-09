class GraphsController < ApplicationController
  before_filter :authenticate
  # GET /graphs
  # GET /graphs.json
  def index
    @graphs = Graph.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @graphs }
    end
  end

  # GET /graphs/1
  # GET /graphs/1.json
  def show
    @graph = Graph.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @graph }
    end
  end

  # GET /graphs/new
  # GET /graphs/new.json
  def new
    @project = Project.find(params[:project_id])
    @graph = Graph.new
    @resource_types = RESOURCE_TYPES

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @graph }
    end
  end

  # GET /graphs/1/edit
  def edit
    @project = Project.find(params[:project_id])
    @graph = Graph.find(params[:id])
    @resource_types = RESOURCE_TYPES
  end

  # POST /graphs
  def create
    errors = []
    @project = Project.find(params[:project_id])
    @graph = Graph.new(params[:graph])
    @graph.project = @project
    if !@graph.save
      errors << "Environment has the following errors :"
      errors += @graph.errors.full_messages
    end

    saved_doms = {}
    params[:instances].to_a.each do |instance|
      resouce_type_name = instance.delete(:resource_type)
      dom_id = instance.delete(:dom_id)
      parent_dom_ids = instance.delete(:parent_dom_ids)
      config_attributes = instance.delete(:config_attributes).to_json
      resource_type = ResourceType.where(name: resouce_type_name).first
      instance = Instance.new(instance)
      instance.config_attributes = config_attributes
      instance.graph = @graph
      instance.resource_type = resource_type
      if !instance.save
        errors << "#{instance.label} has the following error(s) :"
        errors += instance.errors.full_messages
      else
        saved_doms[dom_id] = { instance: instance, parent_dom_ids: parent_dom_ids }
      end
    end

    save_connections(saved_doms)

    if errors.blank?
      flash[:success] = "Environment saved successfully."
    else
      flash.now[:error] = errors
    end

  rescue Exception => e
    puts e.inspect
    puts e.backtrace
    logger.error("Error occured while saving the environment : #{e.inspect}")
    flash.now[:error] = "Error occured while saving the Environment."
    errors << "Error occured while saving the Environment"
  ensure
    respond_to do |format|
      format.js
    end
  end

  # PUT /graphs/1
  def update
    @project = Project.find(params[:project_id])
    @graph = Graph.find(params[:id])
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

  # DELETE /graphs/1
  # DELETE /graphs/1.json
  def destroy
    @project = Project.find(params[:project_id])
    @graph = Graph.find(params[:id])
    if current_user.aws_access_key.nil? || current_user.aws_secret_key.nil?
      flash[:error] = "You have not added your AWS access key"
    else
      if @graph.delete_stack(current_user.aws_access_key, current_user.aws_secret_key)
        if @graph.destroy
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
    @graph = Graph.find(params[:id])
    @errors = []
    update_instances
    if current_user.aws_access_key.nil? || current_user.aws_secret_key.nil?
      @errors << "You have not added your AWS access key"
      flash.now[:error] = @errors
    else
      if @graph.provision(current_user.aws_access_key, current_user.aws_secret_key)
        flash.now[:success] = "Provision request initiated"
      else
        @errors << "This environment cannot be provisioned"
        flash.now[:error] = @errors
      end
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
        record.save
      end
    end

    def update_instances
    @graph.instances.destroy_all

    saved_doms = {}
    params[:instances].to_a.each do |instance|
      resouce_type_name = instance.delete(:resource_type)
      dom_id = instance.delete(:dom_id)
      parent_dom_ids = instance.delete(:parent_dom_ids)
      config_attributes = instance.delete(:config_attributes).to_json
      resource_type = ResourceType.where(name: resouce_type_name).first
      instance = Instance.new(instance)
      instance.config_attributes = config_attributes
      instance.graph = @graph
      instance.resource_type = resource_type
      if !instance.save
        @errors << "#{instance.label} has the following error(s) :"
        @errors += instance.errors.full_messages
      else
        saved_doms[dom_id] = { instance: instance, parent_dom_ids: parent_dom_ids }
      end
    end

    save_connections(saved_doms)
    end

end
