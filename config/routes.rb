require 'sidekiq/web'

VisualCloud::Application.routes.draw do

  # Sidekiq queue monitoring
  constraint = lambda { |request| request.env["warden"].authenticate? and request.env['warden'].user.has_role?('admin') }
  constraints constraint do
    mount Sidekiq::Web => '/sidekiq'
  end

  authenticated :user do
    root :to => 'projects#index'
    get 'environment_status' => 'environments#environment_status'
    get 'stack_status' => 'environments#stack_status'
    get 'instance_status' => 'instances#status'
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
