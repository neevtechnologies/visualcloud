class DeploysController < ApplicationController
  # GET /deploys
  # GET /deploys.json
  def index
    @deploys = Deploy.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @deploys }
    end
  end

  # GET /deploys/1
  # GET /deploys/1.json
  def show
    @deploy = Deploy.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @deploy }
    end
  end

  # GET /deploys/new
  # GET /deploys/new.json
  def new
    @deploy = Deploy.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @deploy }
    end
  end

  # GET /deploys/1/edit
  def edit
    @deploy = Deploy.find(params[:id])
  end

  # POST /deploys
  # POST /deploys.json
  def create
    @deploy = Deploy.new(params[:deploy])
    @project = Project.find(params[:project_id])
    respond_to do |format|
      if @deploy.save
        format.html { redirect_to project_path(@project), notice: 'Deploy was successfully created.' }
        format.json { render json: @deploy, status: :created, location: @deploy }
      else
        format.html { render action: "new" }
        format.json { render json: @deploy.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /deploys/1
  # PUT /deploys/1.json
  def update
    @deploy = Deploy.find(params[:id])

    respond_to do |format|
      if @deploy.update_attributes(params[:deploy])
        format.html { redirect_to @deploy, notice: 'Deploy was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @deploy.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /deploys/1
  # DELETE /deploys/1.json
  def destroy
    @deploy = Deploy.find(params[:id])
    @deploy.destroy

    respond_to do |format|
      format.html { redirect_to deploys_url }
      format.json { head :no_content }
    end
  end
end
