require 'spec_helper'

describe GraphsController do

  describe "POST #create" do
    def do_post
      post :create, graph: {name: 'testGraph'}, instances: [{label:'WebServer', xpos: 10, ypos: 20, ami_id: 1},{label: 'MySQL', xpos: 5, ypos: 15}]
    end

    let(:user) { FactoryGirl.create(:user) }

    it "should increase the graph cound by 1" do
      sign_in(user)
      expect do
        do_post 
      end.to change {Graph.count}.by(1)
    end

    it "should increase the instance cound by 2" do
      sign_in(user)
      expect do
        do_post 
      end.to change {Instance.count}.by(2)
    end

    
  end

end
