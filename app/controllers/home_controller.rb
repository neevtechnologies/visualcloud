class HomeController < ApplicationController
  before_filter :authenticate_user! , except: [:index]

#Displaying the home page
  def index
  end

  def dashboard
  end
end
