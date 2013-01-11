require 'spec_helper'

describe ProjectsController do

  before (:each) do
    @user = FactoryGirl.create(:user)
    sign_in @user
    @rails_project = FactoryGirl.create(:project, name: 'RailsProject')
    @rails_dev_env = FactoryGirl.create(:environment, name: 'RailsDevEnv', project: @rails_project, provision_status: 'CREATE_COMPLETE')
    @rails_test_env = FactoryGirl.create(:environment, name: 'RailsTestEnv', project: @rails_project, provision_status: 'CREATE_IN_PROGRESS')
    @java_project = FactoryGirl.create(:project, name: 'JavaProject')
    @java_dev_env = FactoryGirl.create(:environment, name: 'javaDevEnv', project: @java_project)
    @java_test_env = FactoryGirl.create(:environment, name: 'javaTestEnv', project: @java_project)
  end

  describe "GET status" do
    it "response should be success" do
      xhr :get, :status, :id => @rails_project.id
      response.should be_success
    end
    it "should return status of all environments as json" do
      xhr :get, :status, :id => @rails_project.id
      response.body.should == {
        @rails_dev_env.id => 'CREATE_COMPLETE',
        @rails_test_env.id => 'CREATE_IN_PROGRESS'
      }.to_json
    end
  end
end
