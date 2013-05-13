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
    get 'stack_info' => 'environments#status'
    get 'project_status' => 'projects#status'
    get 'get_key_pairs_and_security_groups' => 'environments#get_key_pairs_and_security_groups'
    match 'export_csv' => 'environments#export_csv'
    #Environment resource
    resources :projects do
      resources :environments, except: [:index, :show]
    end

    post 'provision' => 'environments#provision'
  end
  root :to => "home#index"
  devise_for :users
  resources :users, :only => [:show, :index]

  # Workaround to solve the following problem :
  # https://github.com/rails/rails/issues/671
  match '*a', to: 'application#authenticate'
end
