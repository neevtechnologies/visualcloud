VisualCloud::Application.routes.draw do

  authenticated :user do
    root :to => 'projects#index'
    #Graph resource
    resources :projects do
      resources :graphs
    end
    #Instance resource
    resources :instances
    post 'create_ec2' => 'instances#create_ec2'
    post 'create_rds' => 'instances#create_rds'
    post 'provision_graph' => 'graphs#provision'
  end
  root :to => "home#index"
  devise_for :users
  resources :users, :only => [:show, :index]

  # Workaround to solve the following problem :
  # https://github.com/rails/rails/issues/671
  match '*a', to: 'application#authenticate'
end
