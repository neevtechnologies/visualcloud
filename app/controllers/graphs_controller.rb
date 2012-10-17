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
    @graph = Graph.new
    @resource_types = RESOURCE_TYPES

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @graph }
    end
  end

  # GET /graphs/1/edit
  def edit
    @graph = Graph.find(params[:id])
    @resource_types = RESOURCE_TYPES
  end

  # POST /graphs
  # POST /graphs.json
  def create
    errors = []
    graph = Graph.new(params[:graph])
    if !graph.save
      errors << "Graph has the following errors :"
      errors += graph.errors.full_messages
    end

    params[:instances].to_a.each do |instance|
      resouce_type_name = instance.delete(:resource_type)
      resource_type = ResourceType.where(name: resouce_type_name).first
      instance = Instance.new(instance)
      instance.graph = graph
      instance.resource_type = resource_type
      if !instance.save
        errors << "#{instance.label} has the following error(s) :"
        errors += instance.errors.full_messages
      end
    end

    if errors.blank?
      flash.now[:success] = "Graph saved successfully"
    else
      flash.now[:error] = errors
    end

=begin
    respond_to do |format|
      if @graph.save
        format.html { redirect_to @graph, notice: 'Graph was successfully created.' }
        format.json { render json: @graph, status: :created, location: @graph }
      else
        format.html { render action: "new" }
        format.json { render json: @graph.errors, status: :unprocessable_entity }
      end
    end
=end
  rescue Exception => e
    puts e.inspect
    logger.error("Error occured while saving the graph : #{e.inspect}")
    flash.now[:error] = "Error occured while saving the Graph"
  ensure
    respond_to do |format|
      format.js
    end
  end

  # PUT /graphs/1
  # PUT /graphs/1.json
  def update
    @graph = Graph.find(params[:id])
    @graph.instances.destroy_all
    errors = []

    params[:instances].to_a.each do |instance|
      resouce_type_name = instance.delete(:resource_type)
      resource_type = ResourceType.where(name: resouce_type_name).first
      instance = Instance.new(instance)
      instance.graph = @graph
      instance.resource_type = resource_type
      if !instance.save
        errors << "#{instance.label} has the following error(s) :"
        errors += instance.errors.full_messages 
      end
    end

    if errors.blank?
      flash.now[:success] = "Graph updated successfully"
    else
      flash.now[:error] = errors
    end

    respond_to do |format|
      format.js
    end
  end

  # DELETE /graphs/1
  # DELETE /graphs/1.json
  def destroy
    @graph = Graph.find(params[:id])
    @graph.destroy

    respond_to do |format|
      format.html { redirect_to graphs_url }
      format.json { head :no_content }
    end
  end
end
