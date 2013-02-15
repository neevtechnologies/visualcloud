# TODO : Code Review: check if this controller is used
class HomeController < ApplicationController
  before_filter :authenticate_user! , except: [:index]
  # TODO  : Code Review: check if users need to be loaded here
  def index
    @users = User.all
  end

  def dashboard
  end
end
