require 'spec_helper'

describe GraphsController do

  # This should return the minimal set of attributes required to create a valid
  # Graph. As you add validations to Graph, be sure to
  # update the return value of this method accordingly.
  def valid_attributes
    { name: "Test" }
  end

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # GraphsController. Be sure to keep this updated too.
  def valid_session
    {}
  end

  describe "GET index" do
    it "assigns all graphs as @graphs" do
      graph = Graph.create! valid_attributes
      get :index, {}, valid_session
      assigns(:graphs).should eq([graph])
    end
  end

  describe "GET show" do
    it "assigns the requested graph as @graph" do
      graph = Graph.create! valid_attributes
      get :show, {:id => graph.to_param}, valid_session
      assigns(:graph).should eq(graph)
    end
  end

  describe "GET new" do
    it "assigns a new graph as @graph" do
      get :new, {}, valid_session
      assigns(:graph).should be_a_new(Graph)
    end
  end

  describe "GET edit" do
    it "assigns the requested graph as @graph" do
      graph = Graph.create! valid_attributes
      get :edit, {:id => graph.to_param}, valid_session
      assigns(:graph).should eq(graph)
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new Graph" do
        expect {
          post :create, {:graph => valid_attributes}, valid_session
        }.to change(Graph, :count).by(1)
      end

      it "assigns a newly created graph as @graph" do
        post :create, {:graph => valid_attributes}, valid_session
        assigns(:graph).should be_a(Graph)
        assigns(:graph).should be_persisted
      end

      it "redirects to the created graph" do
        post :create, {:graph => valid_attributes}, valid_session
        response.should redirect_to(Graph.last)
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved graph as @graph" do
        # Trigger the behavior that occurs when invalid params are submitted
        Graph.any_instance.stub(:save).and_return(false)
        post :create, {:graph => {}}, valid_session
        assigns(:graph).should be_a_new(Graph)
      end

      it "re-renders the 'new' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        Graph.any_instance.stub(:save).and_return(false)
        post :create, {:graph => {}}, valid_session
        response.should render_template("new")
      end
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      it "updates the requested graph" do
        graph = Graph.create! valid_attributes
        # Assuming there are no other graphs in the database, this
        # specifies that the Graph created on the previous line
        # receives the :update_attributes message with whatever params are
        # submitted in the request.
        Graph.any_instance.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, {:id => graph.to_param, :graph => {'these' => 'params'}}, valid_session
      end

      it "assigns the requested graph as @graph" do
        graph = Graph.create! valid_attributes
        put :update, {:id => graph.to_param, :graph => valid_attributes}, valid_session
        assigns(:graph).should eq(graph)
      end

      it "redirects to the graph" do
        graph = Graph.create! valid_attributes
        put :update, {:id => graph.to_param, :graph => valid_attributes}, valid_session
        response.should redirect_to(graph)
      end
    end

    describe "with invalid params" do
      it "assigns the graph as @graph" do
        graph = Graph.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        Graph.any_instance.stub(:save).and_return(false)
        put :update, {:id => graph.to_param, :graph => {}}, valid_session
        assigns(:graph).should eq(graph)
      end

      it "re-renders the 'edit' template" do
        graph = Graph.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        Graph.any_instance.stub(:save).and_return(false)
        put :update, {:id => graph.to_param, :graph => {}}, valid_session
        response.should render_template("edit")
      end
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested graph" do
      graph = Graph.create! valid_attributes
      expect {
        delete :destroy, {:id => graph.to_param}, valid_session
      }.to change(Graph, :count).by(-1)
    end

    it "redirects to the graphs list" do
      graph = Graph.create! valid_attributes
      delete :destroy, {:id => graph.to_param}, valid_session
      response.should redirect_to(graphs_url)
    end
  end

end
