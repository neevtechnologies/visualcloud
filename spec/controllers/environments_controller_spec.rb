require 'spec_helper'

describe EnvironmentsController do

  let(:user) { FactoryGirl.create(:user) }
  let(:project) { FactoryGirl.create(:project) }

  describe "POST #create" do
    def do_post(project_id)
      post :create, project_id: project_id,environment: {name: 'testEnvironment'}, instances: [{label:'WebServer', xpos: 10, ypos: 20, instance_type_id:1,resource_type: 'Rails',config_attributes:{}},{label: 'MySQL', xpos: 5, ypos: 15, instance_type_id:1,resource_type: 'Mysql',config_attributes:{}}]
    end    

    it "should increase the environment count by 1" do
      sign_in(user)
      expect do
        do_post(project.id)
      end.to change {Environment.count}.by(1)
    end

    it "should increase the instance count by 2" do
      sign_in(user)
      expect do
        do_post(project.id)
      end.to change {Instance.count}.by(2)
    end
  end

  describe "POST #update" do
    def do_put(project_id,id)
      put :update, project_id: project_id, id: id, instances: [{label:'WebServerEdited', xpos: 10, ypos: 20, instance_type_id:1,resource_type: 'Rails',config_attributes:{}},{label: 'MySQLEdited', xpos: 5, ypos: 15, instance_type_id:1,resource_type: 'Mysql',config_attributes:{}}]
    end

    
    let(:environment) {FactoryGirl.create(:environment)}
    let(:ec2_instance) { FactoryGirl.create(:ec2_instance, environment: environment) }
    let(:rds_instance) { FactoryGirl.create(:rds_instance, environment: environment) }

    before(:each) do
      environment.instances = [ec2_instance, rds_instance]
    end

    it "should not increase the environment count" do
      sign_in(user)
      expect do
        do_put(project.id,environment.id)
      end.to change {Environment.count}.by(0)
    end

    it "should not increase the instance count" do
      sign_in(user)
      expect do
        environment.instances.count.should == 2
        do_put(project.id,environment.id)
      end.to change {Instance.count}.by(0)
    end

    it "should update the instances" do
      sign_in(user)
      expect do
        do_put(project.id,environment.id)
        environment.reload
        environment.instances.first.label.should == 'WebServerEdited'
        environment.instances.second.label.should == 'MySQLEdited'
      end.to change {Instance.count}.by(0)
    end
  end

end
