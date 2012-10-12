VisualCloud::Application.routes.draw do

  authenticated :user do
    root :to => 'home#dashboard'
    #Graph resource
    resources :graphs
    #Instance resource
    resources :instances
    post 'create_ec2' => 'instances#create_ec2'
    post 'create_rds' => 'instances#create_rds'
  end
  root :to => "home#index"
  devise_for :users
  resources :users, :only => [:show, :index]
end
