Visual Cloud
============

VisualCloud makes creating your environments' stacks in the cloud as easy as :

1. Drag and drop the resources you need in your stack. Load balancer ? Rails/Java App Server ? DB ? You got it.
2. Connect them with lines.
3. Save this stack as an Environment, say "Staging"
4. Click "Provision"
5. Grab a coffee while your cloud is provisioned and your software gets installed

## Screenshots
-Add screenshots here-

## Getting Started

VisualCloud uses Sidekiq for background jobs and MySQL for database.
So you need redis-server and mysql-server.

Clone the repository and follow these steps.

### 'development' environment

```shell
cp config/database.yml.example config/database.yml
# Make any changes to database.yml if required
bundle install
bundle exec rake secret > secret_token
bundle exec rake db:create
bundle exec rake db:migrate
bundle exec rake db:seed
foreman start
```

foreman should start thin, sidekiq and spork.

### 'production' environment
```shell
export RAILS_ENV=production
cp config/database.yml.example config/database.yml
#Make any changes to database.yml if required
bundle install
bundle exec rake secret > secret_token
Edit config/config.yml and set attr_encryption_salt to a random string
bundle exec rake db:create
bundle exec rake db:migrate
#Edit default users and run bundle exec rake db:seed
bundle exec rake assets:precompile
bundle exec sidekiq -e producion
bundle exec rails s -e production
```
