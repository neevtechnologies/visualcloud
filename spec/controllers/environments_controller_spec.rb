require 'spec_helper'

describe EnvironmentsController do

  describe "POST #create" do
    def do_post
      post :create, environment: {name: 'testEnvironment'}, instances: [{label:'WebServer', xpos: 10, ypos: 20, ami_id: 1},{label: 'MySQL', xpos: 5, ypos: 15}]
    end

    let(:user) { FactoryGirl.create(:user) }

    it "should increase the environment count by 1" do
      sign_in(user)
      expect do
        do_post 
      end.to change {Environment.count}.by(1)
    end

    it "should increase the instance count by 2" do
      sign_in(user)
      expect do
        do_post 
      end.to change {Instance.count}.by(2)
    end
  end

  describe "POST #update" do
    def do_put(id)
      put :update, id: id, instances: [{label:'WebServerEdited', xpos: 10, ypos: 20, ami_id: 1},{label: 'MySQLEdited', xpos: 5, ypos: 15}]
    end

    let(:user) { FactoryGirl.create(:user) }
    let(:environment) {FactoryGirl.create(:environment)}
    let(:ec2_instance) { FactoryGirl.create(:ec2_instance, environment: environment) }
    let(:rds_instance) { FactoryGirl.create(:rds_instance, environment: environment) }

    before(:each) do
      environment.instances = [ec2_instance, rds_instance]
    end

    it "should not increase the environment count" do
      sign_in(user)
      expect do
        do_put(environment.id)
      end.to change {Environment.count}.by(0)
    end

    it "should not increase the instance count" do
      sign_in(user)
      expect do
        graph.instances.count.should == 2
        do_put(environment.id)
      end.to change {Instance.count}.by(0)
    end

    it "should update the instances" do
      sign_in(user)
      expect do
        do_put(environment.id)
        environment.reload
        environment.instances.first.label.should == 'WebServerEdited'
        environment.instances.second.label.should == 'MySQLEdited'
      end.to change {Instance.count}.by(0)
    end
  end

end
