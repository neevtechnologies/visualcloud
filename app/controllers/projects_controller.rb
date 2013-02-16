# TODO : Code Review: add permission check in edit/view/update/delete
class ProjectsController < ApplicationController
  include ServerMetaData
  include AwsCompatibleName
  before_filter :authenticate
  before_filter :authorize, :only => [:show, :update, :edit, :destroy]
  # GET /projects
  # GET /projects.json
  def index
    @projects = current_user.projects
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @projects }
    end
  end

  # GET /projects/1
  # GET /projects/1.json
  def show
    @project = Project.find(params[:id])
    @environments = @project.environments
  end

  # GET /projects/new
  # GET /projects/new.json
  def new
    @project = Project.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @project }
    end
  end

  # GET /projects/1/edit
  def edit
    @project = Project.find(params[:id])
    @environments = @project.environments
  end

  # POST /projects
  # POST /projects.json
  def create
    @project = Project.new(params[:project])
    update_project_data_bag(@project)
    @project.users << current_user
    respond_to do |format|
      if @project.save
        format.html { redirect_to projects_path, notice: 'Project was successfully created.' }
        format.json { render json: @project, status: :created, location: @project }
      else
        format.html { render action: "new" }
        format.json { render json: @project.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /projects/1
  # PUT /projects/1.json
  def update
    @project = Project.find(params[:id])
    respond_to do |format|
      if @project.update_attributes(params[:project])
        update_project_data_bag(@project)
        format.html { redirect_to project_path(@project), notice: 'Project was successfully updated.' }
        format.json { head :no_content }
      else
        @environments = @project.environments
        format.html { render action: "edit" }
        format.js { render js: @project.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /projects/1
  # DELETE /projects/1.json
  def destroy
    @project = Project.find(params[:id])
    if @project.destroy
      flash[:success] = "Project deleted successfully."
    else
      flash[:error] = "An error occured while trying to delete project."
    end
    respond_to do |format|
      format.html { redirect_to projects_url }
      format.json { head :no_content }
    end
  end


  #Get the status of all environments belonging to the project
  #TODO: Use this to set the status of environments in project show page
  def status
    @project = Project.find(params[:id])
    environments = @project.environments
    status = {}
    environments.each do |env|
      status[env.id] = env.provision_status
    end
    render json: status
  end

  private

    #Project should belong to the user
    def authorize
      @project = Project.find_by_user_id_and_id(current_user.id,params[:id])
      raise CanCan::AccessDenied, "Nothing to see here, move on" if @project.nil?
    end

end
