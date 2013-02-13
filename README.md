Visual Cloud
============

# Ruby on Rails

This application requires:

* Ruby version 1.9.3
* Rails version 3.2.12

# Database

This application uses MySQL with ActiveRecord.

# Development
* Template Engine: ERB
* Testing Framework: RSpec and Factory Girl
* Front-end Framework: Twitter Bootstrap (Sass)
* Form Builder: SimpleForm
* Authentication: Devise
* Authorization: CanCan

#Delayed/Parallel jobs
VisualCloud uses Sidekiq for background jobs. You need to have a redis-server to be running.

# Getting Started

### 'development' environment

cp config/database.yml.example config/database.yml (Make any changes to database.yml if required)
bundle install
bundle exec rake secret > secret_token
bundle exec rake db:create
bundle exec rake db:migrate
bundle exec rake db:seed
foreman start

foreman should start thin, sidekiq and spork.

### 'production' environment

export RAILS_ENV=production
cp config/database.yml.example config/database.yml (Make any changes to database.yml if required)
bundle install
bundle exec rake secret > secret_token
Edit config/config.yml and set attr_encryption_salt to a random string
bundle exec rake db:create
bundle exec rake db:migrate
Edit default users and run bundle exec rake db:seed
bundle exec rake assets:precompile
bundle exec sidekiq -e producion
bundle exec rails s -e production
