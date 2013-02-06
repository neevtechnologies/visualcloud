require 'spec_helper'

describe ProjectsController do

  before (:each) do
    @user = FactoryGirl.create(:user)
    sign_in @user
    @rails_project = FactoryGirl.create(:project)
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

  describe 'GET #index' do

    it 'does not redirect' do
      get :index
      response.should_not be_redirect
    end

    it "renders the index template" do
      get :index
      response.should render_template("projects/index")
    end

  end

  describe 'GET #new' do
    it 'does not redirect' do
      Project.should_receive(:new)
      get :new
      response.should_not be_redirect
    end

    it "renders the new template" do
      Project.should_receive(:new)
      get :new
      response.should render_template("projects/new")
    end

  end

  describe "POST #create" do

    def do_post
      controller.stub(:update_project_data_bag)
      post :create, name: 'testProject'
    end

    it "should increase the project count by 1" do
      expect do
        do_post
      end.to change {Project.count}.by(1)
    end

    it "should give flash notice message" do
      do_post
      flash[:notice].should == "Project was successfully created."
    end

    it "should redirect to index page" do
      do_post
      response.should be_redirect
    end
  end

  describe 'GET #edit' do
    it 'does not redirect' do
      Project.should_receive(:find).and_return(@rails_project)
      get :edit , id: @rails_project.id
      response.should_not be_redirect
    end
  end

  describe "PUT #update" do
    def do_put(id)
      controller.stub(:update_project_data_bag)
      put :update, id: id , project: {name: 'testProjectUpdate'}
    end

    it "should not increase the project count" do
      expect do
        do_put(@rails_project.id)
      end.to change {Project.count}.by(0)
    end

    it "should update the project" do
      expect do
        do_put(@rails_project.id)
        @rails_project.reload
        @rails_project.name.should == 'testProjectUpdate'
      end.to change {Project.count}.by(0)
    end

    it "should redirect to show page" do
      do_put(@rails_project.id)
      response.should redirect_to(project_path(@rails_project.id))
    end

  end

  describe 'GET #show' do

    it 'does not redirect' do
      #      cloud = double(:cloud)
      #      key_pairs = ['kp1', 'kp2']
      #      security_groups = ['sg1', 'sg2']
      #      cloud.stub(:get_key_pairs).and_return(key_pairs)
      #      cloud.stub(:get_security_groups).and_return(security_groups)
      #      Cloudster::Cloud.stub(:new).and_return(cloud)
      controller.should_receive(:current_user).exactly(2).times.and_return(@user)
      @user.should_receive(:get_key_pair_and_security_groups)
      get :show , id: @rails_project.id
      response.should_not be_redirect
    end
  end

  describe "DELETE #destroy" do

    def to_destroy(id)
      DeleteDataBagWorker.should_receive(:perform_async)
      UpdateProjectDataBagWorker.should_receive(:perform_async).exactly(2).times
      delete :destroy, :id => id
    end

    it "redirects back" do
      to_destroy(@rails_project.id)
      response.should be_redirect
    end

    it "removes a project" do
      expect {
        to_destroy(@rails_project.id)
      }.to change { Project.count }.by(-1)
    end

    it "should give flash success message" do
      to_destroy(@rails_project.id)
      flash[:success].should == "Project deleted successfully."
    end

    it "should give flash error message" do
      Project.should_receive(:find).and_return(@rails_project)
      @rails_project.should_receive(:destroy).and_return(false)
      delete :destroy, :id => @rails_project.id
      flash[:error].should == "An error occured while trying to delete project."
    end
  end

end
