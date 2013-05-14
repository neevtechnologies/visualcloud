require 'spec_helper'

describe EnvironmentsController do

  let(:user) { FactoryGirl.create(:user) }
  let(:project) { FactoryGirl.create(:project, users: [user] ) }


  describe "POST #create" do
    def do_post(project_id)
      Project.should_receive(:find_by_user_id_and_id).with(user.id,project.id.to_s).and_return(project)
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

    let(:environment) {FactoryGirl.create(:environment)}
    let(:ec2_instance) { FactoryGirl.create(:ec2_instance, environment: environment) }
    let(:rds_instance) { FactoryGirl.create(:rds_instance, environment: environment) }

    def do_put(project_id,id)
      Project.should_receive(:find_by_user_id_and_id).with(user.id,environment.project_id).and_return(project)
      DeleteNodeWorker.should_receive(:perform_async).exactly(2).times
      DeleteDataBagWorker.should_receive(:perform_async).exactly(2).times
      put :update, project_id: project_id, id: id, instances: [{label:'WebServerEdited', xpos: 10, ypos: 20, instance_type_id:1,resource_type: 'Rails',config_attributes:{}},{label: 'MySQLEdited', xpos: 5, ypos: 15, instance_type_id:1,resource_type: 'Mysql',config_attributes:{}}]
    end

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


  describe "DELETE #destory" do

    let(:environment) {FactoryGirl.create(:environment , project: project)}
    let(:ec2_instance) { FactoryGirl.create(:ec2_instance, environment: environment) }
    let(:rds_instance) { FactoryGirl.create(:rds_instance, environment: environment) }

    before(:each) do
      Environment.should_receive(:find).and_return(environment)
      environment.instances = [ec2_instance, rds_instance]
    end

    def do_destroy(id,project_id)
      Project.should_receive(:find_by_user_id_and_id).with(user.id,environment.project_id).and_return(project)
      UpdateProjectDataBagWorker.should_receive(:perform_async)
      DeleteNodeWorker.should_receive(:perform_async).exactly(2).times
      DeleteDataBagWorker.should_receive(:perform_async).exactly(2).times
      delete :destroy, :id => id ,:project_id => project_id
    end

    it "redirects back" do
      sign_in(user)
      Project.should_receive(:find_by_user_id_and_id).with(user.id,environment.project_id).and_return(project)
      environment.should_receive(:delete_stack).with(user.aws_access_key, user.aws_secret_key)
      delete :destroy , :project_id => environment.project_id , :id => environment.id
      response.should be_redirect
    end

    it "removes a environment" do
      sign_in(user)
      expect {
        environment.should_receive(:delete_stack).with(user.aws_access_key, user.aws_secret_key).and_return(true)
        do_destroy(environment.id,environment.project_id)
      }.to change { Environment.count }.by(-1)
    end

    it "should give flash success message" do
      sign_in(user)
      environment.should_receive(:delete_stack).with(user.aws_access_key, user.aws_secret_key).and_return(true)
      do_destroy(environment.id,environment.project_id)
      flash[:success].should == "Environment deleted successfully."
    end

    it "should give flash error message for not having the 'aws access' to the user" do
      @user = FactoryGirl.create(:user,email: "abc@gmail.com",aws_secret_key: nil,aws_access_key: nil)
      sign_in(@user)
      Project.should_receive(:find_by_user_id_and_id).with(@user.id,environment.project_id).and_return(project)
      delete :destroy , :project_id => environment.project_id , :id => environment.id
      flash[:error].should == "You have not added your AWS access key"
    end

    it "should give flash error message facing problem while removing the environment" do
      sign_in(user)
      Project.should_receive(:find_by_user_id_and_id).with(user.id,environment.project_id).and_return(project)
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
      xhr :post, :provision , :id => id
    end

    it "should not redirect" do
      sign_in(user)
      Environment.should_receive(:find).exactly(2).times.and_return(environment)
      Project.should_receive(:find_by_user_id_and_id).with(user.id,environment.project_id).and_return(project)
      environment.should_receive(:provision).with(user.aws_access_key, user.aws_secret_key)
      do_provision(environment.id)
      response.should_not be_redirect
    end

    it "should give flash success message" do
      sign_in(user)
      Environment.should_receive(:find).exactly(2).times.and_return(environment)
      Project.should_receive(:find_by_user_id_and_id).with(user.id,environment.project_id).and_return(project)
      environment.should_receive(:provision).with(user.aws_access_key, user.aws_secret_key).and_return(true)
      RoleAssignmentWorker.should_receive(:perform_async)
      do_provision(environment.id)
      flash[:success].should == "Provision request initiated"
    end

    it "should give flash error message for not having the 'aws access' to the user" do
      @user = FactoryGirl.create(:user,email: "xyz@gmail.com",aws_secret_key: nil,aws_access_key: nil)
      Project.should_receive(:find_by_user_id_and_id).with(@user.id,environment.project_id).and_return(project)
      sign_in(@user)
      do_provision(environment.id)
      errors = []
      errors << "You have not added your AWS access key"
      flash[:error].should == errors
    end

    it "should give flash error message facing problem while provisioning the environment" do
      sign_in(user)
      Environment.should_receive(:find).exactly(2).times.and_return(environment)
      Project.should_receive(:find_by_user_id_and_id).with(user.id,environment.project_id).and_return(project)
      environment.should_receive(:provision).with(user.aws_access_key, user.aws_secret_key).and_return(false)
      do_provision(environment.id)
      errors = []
      errors << "This environment cannot be provisioned"
      flash[:error].should == errors
    end
  end

  describe "#export_csv" do
    let(:region) {FactoryGirl.create(:region)}
    let(:resource_type_ec2) { FactoryGirl.create(:resource_type,resource_class: "EC2") }
    let(:resource_type_rds) { FactoryGirl.create(:resource_type,resource_class: "RDS") }
    let(:environment) {FactoryGirl.create(:environment , project: project , region: region)}
    let(:ec2_instance) { FactoryGirl.create(:ec2_instance, environment: environment, resource_type: resource_type_ec2) }
    let(:rds_instance) { FactoryGirl.create(:rds_instance, environment: environment, resource_type: resource_type_rds) }

    it "should be success" do
      sign_in(user)
      Project.should_receive(:find_by_user_id_and_id).with(user.id,environment.project_id).and_return(project)
      get :export_csv, :id => environment.id
      response.should be_success
    end
  end


  describe "#start_ec2_instances" do

    let(:environment) {FactoryGirl.create(:environment , project: project, provision_status: nil)}
    let(:ec2_instance) { FactoryGirl.create(:ec2_instance, environment: environment) }
    let(:rds_instance) { FactoryGirl.create(:rds_instance, environment: environment) }

    before(:each) do
      environment.instances = [ec2_instance, rds_instance]
    end

    def do_start_ec2_instances(id)
      xhr :get, :start_ec2_instances , :id => id
    end

    it "should not redirect" do
      sign_in(user)
      Environment.should_receive(:find).exactly(1).times.and_return(environment)
      Project.should_receive(:find_by_user_id_and_id).with(user.id,environment.project_id).and_return(project)
      environment.should_receive(:check_status_of_ec2_elements).with("running")
      do_start_ec2_instances(environment.id)
      response.should_not be_redirect
    end

    it "should give flash success message" do
      sign_in(user)
      Environment.should_receive(:find).exactly(1).times.and_return(environment)
      Project.should_receive(:find_by_user_id_and_id).with(user.id,environment.project_id).and_return(project)
      environment.should_receive(:check_status_of_ec2_elements).with("running").and_return(true)
      StartEc2InstancesWorker.should_receive(:perform_async)
      do_start_ec2_instances(environment.id)
      flash[:success].should == "Start request of ec2 instances initiated"
    end

    it "should give flash error message for not having the 'aws access' to the user" do
      @user = FactoryGirl.create(:user,email: "xyz@gmail.com",aws_secret_key: nil,aws_access_key: nil)
      Project.should_receive(:find_by_user_id_and_id).with(@user.id,environment.project_id).and_return(project)
      sign_in(@user)
      do_start_ec2_instances(environment.id)
      errors = []
      errors << "You have not added your AWS access key"
      flash[:error].should == errors
    end

    it "should give flash error message facing problem while provisioning the environment" do
      sign_in(user)
      Environment.should_receive(:find).exactly(1).times.and_return(environment)
      Project.should_receive(:find_by_user_id_and_id).with(user.id,environment.project_id).and_return(project)
      environment.should_receive(:check_status_of_ec2_elements).with("running").and_return(false)
      do_start_ec2_instances(environment.id)
      errors = []
      errors << "Environment is not yet provisioned"
      flash[:error].should == errors
    end

    it "should give flash error message facing problem while provisioning the environment" do
      sign_in(user)
      @environment = FactoryGirl.create(:environment , project: project, provision_status: "CREATE_COMPLETE")
      Environment.should_receive(:find).exactly(1).times.and_return(@environment)
      Project.should_receive(:find_by_user_id_and_id).with(user.id,@environment.project_id).and_return(project)
      @environment.should_receive(:check_status_of_ec2_elements).with("running").and_return(false)
      do_start_ec2_instances(@environment.id)
      errors = []
      errors << "Ec2 instances of this environment are already started"
      flash[:error].should == errors
    end
  end

  describe "#stop_ec2_instances" do

    let(:environment) {FactoryGirl.create(:environment , project: project, provision_status: nil)}
    let(:ec2_instance) { FactoryGirl.create(:ec2_instance, environment: environment) }
    let(:rds_instance) { FactoryGirl.create(:rds_instance, environment: environment) }

    before(:each) do
      environment.instances = [ec2_instance, rds_instance]
    end

    def do_stop_ec2_instances(id)
      xhr :get, :stop_ec2_instances , :id => id
    end

    it "should not redirect" do
      sign_in(user)
      Environment.should_receive(:find).exactly(1).times.and_return(environment)
      Project.should_receive(:find_by_user_id_and_id).with(user.id,environment.project_id).and_return(project)
      environment.should_receive(:check_status_of_ec2_elements).with("stopped")
      do_stop_ec2_instances(environment.id)
      response.should_not be_redirect
    end

    it "should give flash success message" do
      sign_in(user)
      Environment.should_receive(:find).exactly(1).times.and_return(environment)
      Project.should_receive(:find_by_user_id_and_id).with(user.id,environment.project_id).and_return(project)
      environment.should_receive(:check_status_of_ec2_elements).with("stopped").and_return(true)
      StopEc2InstancesWorker.should_receive(:perform_async)
      do_stop_ec2_instances(environment.id)
      flash[:success].should == "Stop request of ec2 instances initiated"
    end

    it "should give flash error message for not having the 'aws access' to the user" do
      @user = FactoryGirl.create(:user,email: "xyz@gmail.com",aws_secret_key: nil,aws_access_key: nil)
      Project.should_receive(:find_by_user_id_and_id).with(@user.id,environment.project_id).and_return(project)
      sign_in(@user)
      do_stop_ec2_instances(environment.id)
      errors = []
      errors << "You have not added your AWS access key"
      flash[:error].should == errors
    end

    it "should give flash error message facing problem while stopping ec2 instances of the environment, for environment not provisioned" do
      sign_in(user)
      Environment.should_receive(:find).exactly(1).times.and_return(environment)
      Project.should_receive(:find_by_user_id_and_id).with(user.id,environment.project_id).and_return(project)
      environment.should_receive(:check_status_of_ec2_elements).with("stopped").and_return(false)
      do_stop_ec2_instances(environment.id)
      errors = []
      errors << "Environment is not yet provisioned"
      flash[:error].should == errors
    end

    it "should give flash error message facing problem while stopping ec2 instances of the environment" do
      sign_in(user)
      @environment = FactoryGirl.create(:environment , project: project, provision_status: "CREATE_COMPLETE")
      Environment.should_receive(:find).exactly(1).times.and_return(@environment)
      Project.should_receive(:find_by_user_id_and_id).with(user.id,@environment.project_id).and_return(project)
      @environment.should_receive(:check_status_of_ec2_elements).with("stopped").and_return(false)
      do_stop_ec2_instances(@environment.id)
      errors = []
      errors << "Ec2 instances of this environment are already stopped"
      flash[:error].should == errors
    end
  end

end
