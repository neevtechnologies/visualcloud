class DeploymentsController < ApplicationController
  # GET /deployments
  # GET /deployments.json
  def index
    @deployments = Deployment.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @deployments }
    end
  end

  # GET /deployments/1
  # GET /deployments/1.json
  def show
    @deployment = Deployment.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @deployment }
    end
  end

  # GET /deployments/new
  # GET /deployments/new.json
  def new
    @deployment = Deployment.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @deployment }
    end
  end

  # GET /deployments/1/edit
  def edit
    @deployment = Deployment.find(params[:id])
  end

  # POST /deployments
  # POST /deployments.json
  def create
    @deployment = Deployment.new(params[:deployment])
    @project = Project.find(params[:project_id])
    respond_to do |format|
      if @deployment.save
        format.html { redirect_to project_path(@project), notice: 'Deployment was successfully created.' }
        format.json { render json: @deployment, status: :created, location: @deployment }
      else
        format.html { render action: "new" }
        format.json { render json: @deployment.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /deployments/1
  # PUT /deployments/1.json
  def update
    @deployment = Deployment.find(params[:id])

    respond_to do |format|
      if @deployment.update_attributes(params[:deployment])
        format.html { redirect_to @deployment, notice: 'Deployment was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @deployment.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /deployments/1
  # DELETE /deployments/1.json
  def destroy
    @deployment = Deployment.find(params[:id])
    @deployment.destroy

    respond_to do |format|
      format.html { redirect_to deployments_url }
      format.json { head :no_content }
    end
  end
end
