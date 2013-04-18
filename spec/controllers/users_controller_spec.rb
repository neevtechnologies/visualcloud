require 'spec_helper'

describe UsersController do

  before (:each) do
    @user = FactoryGirl.create(:user)
    sign_in @user
  end

  describe "GET 'show'" do

    it "should be successful" do
      @user.add_role 'admin'
      get :show, :id => @user.id
      response.should be_success
    end

    it "should find the right user" do
      get :show, :id => @user.id
      assigns(:user).should == @user
    end

    it "should give error message for non admin" do
      get :show, :id => @user.id
      flash[:error].should == "Not authorized as an administrator."
    end

  end

  describe "GET 'index'" do

    it "should be successful" do
      @user.add_role 'admin'
      get :index
      response.should be_success
    end

    it "should get all users" do
      @user.add_role 'admin'
      get :index
      assigns(:users).should == [@user]
    end

    it "should give error message for non admin" do
      get :index
      flash[:error].should == "Not authorized as an administrator."
    end
  end

end
