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

  describe "PUT #update" do
    def do_put(project_id,id)
      DeleteNodeWorker.should_receive(:perform_async).exactly(2).times
      DeleteDataBagWorker.should_receive(:perform_async).exactly(2).times
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

  describe "PUT #update_environment" do

    before(:each) do
      @environment = FactoryGirl.create(:environment)
    end

    def do_put(id)
      xhr :put , :update_environment, id: id, environment: { db_migrate: true, branch: "testBranch" }
    end

    it "response should be success" do
      sign_in(user)
      do_put(@environment.id)
      response.should be_success
    end

    it "should update the enviornment attributes" do
      sign_in(user)
      expect{
        do_put(@environment.id)
        @environment.reload
        @environment.db_migrate.should == true
        @environment.branch.should == "testBranch"
      }.to change {Environment.count}.by(0)
    end

    it "should give flash success message" do
      sign_in(user)
      do_put(@environment.id)
      flash[:success].should == "Environment fields updated successfully."
    end

    it "should give flash error message" do
      sign_in(user)
      Environment.should_receive(:find).and_return(@environment)
      @environment.should_receive(:update_attributes).and_return(false)
      do_put(@environment.id)
      flash[:error].should == "An error occured while trying to update environment fields."
    end

  end

  describe "DELETE #destory" do

    let(:environment) {FactoryGirl.create(:environment , project: project)}
    let(:ec2_instance) { FactoryGirl.create(:ec2_instance, environment: environment) }
    let(:rds_instance) { FactoryGirl.create(:rds_instance, environment: environment) }

    before(:each) do
      environment.instances = [ec2_instance, rds_instance]
    end

   def do_destroy(id,project_id)
     UpdateProjectDataBagWorker.should_receive(:perform_async)
     DeleteNodeWorker.should_receive(:perform_async).exactly(2).times
     DeleteDataBagWorker.should_receive(:perform_async).exactly(2).times
     delete :destroy, :id => id ,:project_id => project_id
   end


    it "redirects back" do
      sign_in(user)
      Environment.should_receive(:find).and_return(environment)
      environment.should_receive(:delete_stack).with(user.aws_access_key, user.aws_secret_key)
      delete :destroy , :project_id => environment.project_id , :id => environment.id
      response.should be_redirect
    end

    it "removes a environment" do
      sign_in(user)
      expect {
        Environment.should_receive(:find).and_return(environment)
        environment.should_receive(:delete_stack).with(user.aws_access_key, user.aws_secret_key).and_return(true)
        do_destroy(environment.id,environment.project_id)
      }.to change { Environment.count }.by(-1)
    end

    it "should give flash success message" do
      sign_in(user)
      Environment.should_receive(:find).and_return(environment)
      environment.should_receive(:delete_stack).with(user.aws_access_key, user.aws_secret_key).and_return(true)
      do_destroy(environment.id,environment.project_id)
      flash[:success].should == "Environment deleted successfully."
    end

    it "should give flash error message for not having the 'aws access' to the user" do
      @user = FactoryGirl.create(:user,aws_secret_key: nil,aws_access_key: nil)
      sign_in(@user)
      delete :destroy , :project_id => environment.project_id , :id => environment.id
      flash[:error].should == "You have not added your AWS access key"
    end

    it "should give flash error message facing problem while removing the environment" do
      sign_in(user)
      Environment.should_receive(:find).and_return(environment)
      environment.should_receive(:delete_stack).with(user.aws_access_key, user.aws_secret_key).and_return(false)
      delete :destroy, :id => environment.id ,:project_id => environment.project_id
      flash[:error].should == "An error occured while trying to delete environment."
    end
  end


 describe "#provision" do

    let(:environment) {FactoryGirl.create(:environment , project: project)}
    let(:ec2_instance) { FactoryGirl.create(:ec2_instance, environment: environment) }
    let(:rds_instance) { FactoryGirl.create(:rds_instance, environment: environment) }

    before(:each) do
      environment.instances = [ec2_instance, rds_instance]
    end

    def do_provision(id)
      DeleteNodeWorker.should_receive(:perform_async).exactly(2).times
      DeleteDataBagWorker.should_receive(:perform_async).exactly(2).times
      xhr :post, :provision , :id => id, environment: { db_migrate: true, branch: "testBranch" }
    end

    it "should not redirect" do
      sign_in(user)
      Environment.should_receive(:find).exactly(2).times.and_return(environment)
      environment.should_receive(:provision).with(user.aws_access_key, user.aws_secret_key)
      do_provision(environment.id)
      response.should_not be_redirect
    end

    it "should give flash success message" do
      sign_in(user)
      Environment.should_receive(:find).exactly(2).times.and_return(environment)
      environment.should_receive(:provision).with(user.aws_access_key, user.aws_secret_key).and_return(true)
      RoleAssignmentWorker.should_receive(:perform_async)
      do_provision(environment.id)
      flash[:success].should == "Provision request initiated"
    end

    it "should give flash error message for not having the 'aws access' to the user" do
      @user = FactoryGirl.create(:user,aws_secret_key: nil,aws_access_key: nil)
      sign_in(@user)
      do_provision(environment.id)
      errors = []
      errors << "You have not added your AWS access key"
      flash[:error].should == errors
    end

    it "should give flash error message facing problem while provisioning the environment" do
      sign_in(user)
      Environment.should_receive(:find).exactly(2).times.and_return(environment)
      environment.should_receive(:provision).with(user.aws_access_key, user.aws_secret_key).and_return(false)
      do_provision(environment.id)
      errors = []
      errors << "This environment cannot be provisioned"
      flash[:error].should == errors
    end
  end

end
