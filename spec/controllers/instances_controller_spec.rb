require 'spec_helper'

describe InstancesController do

  let(:user) { FactoryGirl.create(:user) }

  describe "#stop_ec2_instance" do

    let(:environment) {FactoryGirl.create(:environment , provision_status: nil)}
    let(:ec2_instance) { FactoryGirl.create(:ec2_instance, environment: environment ,instance_status: '') }


    def do_stop_ec2_instance(id)
      xhr :get, :stop_ec2_instance , :id => id
    end

    it "should not redirect" do
      sign_in(user)
      Instance.should_receive(:find).exactly(1).times.and_return(ec2_instance)
      ec2_instance.should_receive(:check_status_of_ec2_element).with("stopped")
      do_stop_ec2_instance(ec2_instance.id)
      response.should_not be_redirect
    end

    it "should give flash success message" do
      sign_in(user)
      Instance.should_receive(:find).exactly(1).times.and_return(ec2_instance)
      ec2_instance.should_receive(:check_status_of_ec2_element).with("stopped").and_return(true)
      StopEc2InstancesWorker.should_receive(:perform_async)
      do_stop_ec2_instance(ec2_instance.id)
      flash[:success].should == "Stop request of ec2 instance initiated"
    end

    it "should give flash error message for not having the 'aws access' to the user" do
      @user = FactoryGirl.create(:user,email: "xyz@gmail.com",aws_secret_key: nil,aws_access_key: nil)
      sign_in(@user)
      do_stop_ec2_instance(ec2_instance.id)
      errors = []
      errors << "You have not added your AWS access key"
      flash[:error].should == errors
    end

    it "should give flash error message facing problem while stopping ec2 instance of the environment, for environment not provisioned" do
      sign_in(user)
      environment.instances = [ec2_instance]
      Instance.should_receive(:find).exactly(1).times.and_return(ec2_instance)
      ec2_instance.should_receive(:check_status_of_ec2_element).with("stopped").and_return(false)
      do_stop_ec2_instance(ec2_instance.id)
      errors = []
      errors << "Environment is not yet provisioned"
      flash[:error].should == errors
    end

    it "should give flash error message facing problem while stopping ec2 instance of the environment" do
      sign_in(user)
      @environment = FactoryGirl.create(:environment , provision_status: "CREATE_COMPLETE")
      @ec2_instance = FactoryGirl.create(:ec2_instance, environment: @environment, instance_status: "stopped")
      Instance.should_receive(:find).exactly(1).times.and_return(@ec2_instance)
      @environment.instances = [@ec2_instance]
      @ec2_instance.should_receive(:check_status_of_ec2_element).with("stopped").and_return(false)
      do_stop_ec2_instance(@ec2_instance.id)
      errors = []
      errors << "Ec2 instance is already stopped"
      flash[:error].should == errors
    end
  end

  describe "#start_ec2_instance" do

    let(:environment) {FactoryGirl.create(:environment , provision_status: nil)}
    let(:ec2_instance) { FactoryGirl.create(:ec2_instance, environment: environment ,instance_status: '') }


    def do_start_ec2_instance(id)
      xhr :get, :start_ec2_instance , :id => id
    end

    it "should not redirect" do
      sign_in(user)
      Instance.should_receive(:find).exactly(1).times.and_return(ec2_instance)
      ec2_instance.should_receive(:check_status_of_ec2_element).with("running")
      do_start_ec2_instance(ec2_instance.id)
      response.should_not be_redirect
    end

    it "should give flash success message" do
      sign_in(user)
      Instance.should_receive(:find).exactly(1).times.and_return(ec2_instance)
      ec2_instance.should_receive(:check_status_of_ec2_element).with("running").and_return(true)
      StartEc2InstancesWorker.should_receive(:perform_async)
      do_start_ec2_instance(ec2_instance.id)
      flash[:success].should == "Start request of ec2 instance initiated"
    end

    it "should give flash error message for not having the 'aws access' to the user" do
      @user = FactoryGirl.create(:user,email: "xyz@gmail.com",aws_secret_key: nil,aws_access_key: nil)
      sign_in(@user)
      do_start_ec2_instance(ec2_instance.id)
      errors = []
      errors << "You have not added your AWS access key"
      flash[:error].should == errors
    end

    it "should give flash error message facing problem while starting ec2 instance of the environment, for environment not provisioned" do
      sign_in(user)
      environment.instances = [ec2_instance]
      Instance.should_receive(:find).exactly(1).times.and_return(ec2_instance)
      ec2_instance.should_receive(:check_status_of_ec2_element).with("running").and_return(false)
      do_start_ec2_instance(ec2_instance.id)
      errors = []
      errors << "Environment is not yet provisioned"
      flash[:error].should == errors
    end

    it "should give flash error message facing problem while starting ec2 instance of the environment" do
      sign_in(user)
      Instance.should_receive(:find).exactly(1).times.and_return(ec2_instance)
      ec2_instance.environment.provision_status = "CREATE_COMPLETE"
      ec2_instance.instance_status = "running"
      environment.instances = [ec2_instance]
      ec2_instance.should_receive(:check_status_of_ec2_element).with("running").and_return(false)
      do_start_ec2_instance(ec2_instance.id)
      errors = []
      errors << "Ec2 instance is already started"
      flash[:error].should == errors
    end
  end

end
