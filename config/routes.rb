VisualCloud::Application.routes.draw do

  authenticated :user do
    root :to => 'projects#index'
    get 'environment_status' => 'environments#status'

    #Environment resource
    resources :projects do
      resources :environments do
        resources :deployments
      end
    end
    #Instance resource
    resources :instances
    post 'create_ec2' => 'instances#create_ec2'
    post 'create_rds' => 'instances#create_rds'
    post 'provision_environment' => 'environments#provision'
    put 'update_environment' => 'environments#update_environment'
  end
  root :to => "home#index"
  devise_for :users
  resources :users, :only => [:show, :index]

  # Workaround to solve the following problem :
  # https://github.com/rails/rails/issues/671
  match '*a', to: 'application#authenticate'
end
