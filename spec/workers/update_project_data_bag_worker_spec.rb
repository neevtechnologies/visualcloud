require 'spec_helper'

describe UpdateProjectDataBagWorker do
  include Sidekiq::Worker

  let(:project) {FactoryGirl.create(:project) }
  let(:environment) { FactoryGirl.create(:environment , project: project) }
  let(:ec2_instance) { FactoryGirl.create(:ec2_instance , environment: environment) }

  before (:each) do
    @update_project_worker = UpdateProjectDataBagWorker.new
    environment.instances = [ec2_instance]
  end

  it "check number of jobs created, once the worker is started and cleared it for the project" do
    input = {'id' => project.id}
    assert_equal 0, UpdateProjectDataBagWorker.jobs.size
    UpdateProjectDataBagWorker.perform_async(input)
    expect(UpdateProjectDataBagWorker).to have(1).jobs
    UpdateProjectDataBagWorker.clear
    assert_equal 0, UpdateProjectDataBagWorker.jobs.size
  end

  it { should be_retryable false }

  describe "#perform" do
    include ServerMetaData

    it "should call update_project_data_bag method" do
      input = {'id' => project.id}
      Project.should_receive(:find).with(input['id']).and_return(project)
      @update_project_worker.should_receive(:update_project_data_bag).with(project)
      @update_project_worker.perform(input)
    end

  end

end
