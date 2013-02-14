source 'https://rubygems.org'
gem 'rails', '3.2.12'
group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'
  gem 'uglifier', '>= 1.0.3'
  gem 'jquery-ui-rails', '~> 3.0.0'
end
gem 'jquery-rails', '~> 2.2.1'
gem "thin", ">= 1.5.0"
gem "mysql2", ">= 0.3.11"
gem "devise", ">= 2.1.2"
gem "cancan", ">= 1.6.8"
gem "attr_encrypted", "~> 1.2.1"
gem "rolify", ">= 3.2.0"
gem 'bootstrap-sass'
gem 'font-awesome-rails', :git => 'git://github.com/bokmann/font-awesome-rails.git'
gem "simple_form", ">= 2.0.3"
gem "therubyracer", "= 0.10.2", :group => :assets, :platform => :ruby
gem "chef", "~> 11.4.0"
gem 'sidekiq'
gem 'sinatra', require: false
gem 'slim'
gem 'colorize'

gem 'cloudster', "~> 2.19.6"

group :development, :test do
  gem "awesome_print"
  gem "debugger"
  gem "spork"
end

group :development do
  gem "better_errors"
  gem "binding_of_caller"
  gem 'foreman'
end

group :test do
  gem 'test-unit', :require => "test/unit"
  gem "rspec-rails", ">= 2.11.0"#, :group => [:development, :test]
  gem "factory_girl_rails", ">= 4.1.0"#, :group => [:development, :test]
  gem 'shoulda'
  gem "mock_redis"
  gem 'shoulda-matchers'
end
