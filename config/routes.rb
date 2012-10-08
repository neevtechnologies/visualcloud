VisualCloud::Application.routes.draw do
  resources :graphs

  authenticated :user do
    root :to => 'home#dashboard'
  end
  root :to => "home#index"
  devise_for :users
  resources :users, :only => [:show, :index]
end
