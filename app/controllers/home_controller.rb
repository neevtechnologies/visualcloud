class HomeController < ApplicationController
  before_filter :authenticate_user! , except: [:index]
  def index
    @users = User.all
  end

  def dashboard
  end
end
