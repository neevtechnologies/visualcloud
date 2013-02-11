Visual Cloud
============

# Ruby on Rails

This application requires:

* Ruby version 1.9.3
* Rails version 3.2.8

# Database

This application uses MySQL with ActiveRecord.

# Development
* Template Engine: ERB
* Testing Framework: RSpec and Factory Girl
* Front-end Framework: Twitter Bootstrap (Sass)
* Form Builder: SimpleForm
* Authentication: Devise
* Authorization: CanCan

# Email
The application is configured to send email using a SMTP account.

#Delayed/Parallel jobs
We use Sidekiq for this. And for this you need redis-server to be running.

# Getting Started
export RAILS_ENV=production
cp config/database.yml.example config/database.yml (Make any changes to database.yml if required)
bundle install
bundle exec rake secret > secret_token
Edit config/config.yml and set attr_encryption_salt to a random string
bundle exec rake db:create
bundle exec rake db:migrate:reset
bundle exec rake db:seed
bundle exec rake assets:precompile
bundle exec rails s -e production


# Documentation and Support

Go ahead read the code.
