require 'spec_helper'

describe StopEc2InstancesWorker do
  include Sidekiq::Worker

  let(:region) { FactoryGirl.create(:region) }
  let(:environment) { FactoryGirl.create(:environment, region: region) }
  let(:ec2_instance) { FactoryGirl.create(:ec2_instance , environment: environment) }

  before(:each) do
    @worker = StopEc2InstancesWorker.new
    environment.instances = [ec2_instance]
  end

  it "check count once the worker is started and done for the environment" do
    expect(StopEc2InstancesWorker).to have(0).jobs
    StopEc2InstancesWorker.perform_async({:environment_id => environment.id , :access_key_id => "test_id" , :secret_access_key => "test_key"})
    expect(StopEc2InstancesWorker).to have(1).jobs
    StopEc2InstancesWorker.drain
    expect(StopEc2InstancesWorker).to have(0).jobs
  end

  it { should be_retryable false }

  it "check count once the worker is started and done for the instance" do
    assert_equal 0, StopEc2InstancesWorker.jobs.size
    StopEc2InstancesWorker.perform_async(instance_id: ec2_instance.id , access_key_id: "test_id" , secret_access_key: "test_key")
    expect(StopEc2InstancesWorker).to have(1).jobs
    Instance.should_receive(:find).with(ec2_instance.id).and_return(ec2_instance)
    ec2_instance.should_receive(:stop_ec2_instance)
    StopEc2InstancesWorker.drain
    assert_equal 0, StopEc2InstancesWorker.jobs.size
  end

  describe "#perform" do

    it "should call these methods on environment" do
      input = {:environment_id => environment.id , :access_key_id => "test_id" , :secret_access_key => "test_key"}
      Environment.should_receive(:find).with(input[:environment_id]).and_return(environment)
      environment.should_receive(:stop_ec2_instances).with(input[:access_key_id], input[:secret_access_key])
      environment.should_receive(:wait_till_stopped).with(input[:access_key_id], input[:secret_access_key]).and_return(true)
      environment.should_receive(:update_ec2_instances_config_attributes).with("stop", input[:access_key_id], input[:secret_access_key])
      environment.should_receive(:set_meta_data).with(input[:access_key_id], input[:secret_access_key])
      @worker.perform(input)
    end

    it "should call these methods on instance" do
      input = {:instance_id => ec2_instance.id , :access_key_id => "test_id" , :secret_access_key => "test_key"}
      Instance.should_receive(:find).with(input[:instance_id]).and_return(ec2_instance)
      ec2_instance.should_receive(:stop_ec2_instance).with(input[:access_key_id], input[:secret_access_key])
      ec2_instance.should_receive(:wait_till_stopped).with(input[:access_key_id], input[:secret_access_key]).and_return(true)
      ec2_instance.should_receive(:update_status_and_config_attributes).with("stop", input[:access_key_id], input[:secret_access_key])
      environment.should_receive(:set_meta_data).with(input[:access_key_id], input[:secret_access_key])
      @worker.perform(input)
    end
  end

end
