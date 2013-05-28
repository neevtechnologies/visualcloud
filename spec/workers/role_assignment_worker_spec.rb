require 'spec_helper'

describe RoleAssignmentWorker do
  include Sidekiq::Worker

  let(:environment) { FactoryGirl.create(:environment) }
  let(:ec2_instance) { FactoryGirl.create(:ec2_instance , environment: environment) }

  before (:each) do
    environment.instances = [ec2_instance]
  end
  it "check number of jobs created, once the worker is started and cleared it for the environment" do
    assert_equal 0, RoleAssignmentWorker.jobs.size
    RoleAssignmentWorker.perform_async({:environment_id => environment.id , :access_key_id => "test_id" , :secret_access_key => "test_key"})
    expect(RoleAssignmentWorker).to have(1).jobs
    RoleAssignmentWorker.clear
    assert_equal 0, RoleAssignmentWorker.jobs.size
  end
  it { should be_retryable false }

  describe "#perform" do

    it "should call these methods on environment" do
      input = {:environment_id => environment.id , :access_key_id => "test_id" , :secret_access_key => "test_key"}
      Environment.should_receive(:find).with(input[:environment_id]).and_return(environment)
      environment.should_receive(:wait_till_provisioned).with(input[:access_key_id], input[:secret_access_key]).and_return(true)
      environment.should_receive(:update_instance_outputs).with(input[:access_key_id], input[:secret_access_key])
      environment.should_receive(:set_meta_data).with(input[:access_key_id], input[:secret_access_key])
      environment.should_receive(:set_roles)
      RoleAssignmentWorker.new.perform(input)
    end

  end

end
