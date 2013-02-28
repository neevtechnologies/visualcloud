VisualCloud
============
[![Build Status](https://travis-ci.org/neevtechnologies/visualcloud.png?branch=master)](https://travis-ci.org/neevtechnologies/visualcloud)

VisualCloud was designed as a tool to ease the provisioning of a server architecture for
hosting applications on the cloud. Without the use of VisualCloud, deploying a typical
server environment for app hosting on AWS would mean wading through half a dozen screens
with over two dozen different options. VisualCloud makes it easy to draw a deployment
architecture & then provision the servers with the click of a button, all from within a
single screen. Picking a platform (such as Java) will also ensure that the required software
for that platform is automatically setup as well.

VisualCloud makes creating your environments' stacks in the cloud as easy as :

1. Drag and drop the resources you need in your stack. Load balancer ? Rails/Java App Server ? DB ? You got it.
2. Connect them with lines.
3. Save this stack as an Environment, say "Staging"
4. Click "Provision"
5. Grab a coffee while your cloud is provisioned and your software gets installed

# Screenshots
Create a new environment:
![Configure your environment](/screenshots/environment-config.PNG?raw=true)

Add your resources:
![Add resources](/screenshots/environment.JPG?raw=true)

Get the instance details:
![Instance details](/screenshots/instance.PNG?raw=true)

# Getting Started

VisualCloud is a Rails application which uses Sidekiq for
background jobs and MySQL for database.
So you need redis-server and mysql-server.

Clone the repository and follow these steps.

## 'development' environment

```shell
cp config/database.yml.example config/database.yml
# Make changes to database.yml if required
bundle install
bundle exec rake secret > secret_token
bundle exec rake db:create
bundle exec rake db:migrate
bundle exec rake db:seed
foreman start
```

foreman should start thin, sidekiq and spork.

## 'production' environment
```shell
export RAILS_ENV=production
cp config/database.yml.example config/database.yml
#Make changes to database.yml if required
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

# Contribute

VisualCloud started off as a rough prototype and it took a lot of hacking
before it evolved into a stable application. Needless to say, you may find
places where things can be done better/differently. Please do not hesitate to
send a pull request.

It doesn't matter if you are not a Rubyist. You can still contribute.
If you would like to share some love and send some pull requests, you may want
to refer [this Wiki page]() to see how you can help.

## Found a bug?

Log the bug in the [issue tracker](https://github.com/neevtechnologies/visualcloud/issues). Be sure to include all relevant information, like
the versions of Ruby you're using. A [gist](http://gist.github.com/)
of the code that caused the issue as well as any error messages are also very
helpful.

## Need help?

You can use the [Issues](https://github.com/neevtechnologies/visualcloud/issues) page to ask a new question for now. This is how you do it:
1. Click on New Issue.
2. Type in your question and submit.

## Have a patch?

Bugs and feature requests that include patches will be big help.
Here are some guidelines that will help ensure your patch
can be applied as quickly as possible:

1. **Use [Git](http://git-scm.com) and [GitHub](http://github.com):**
   The easiest way to get setup is to fork the
   [visualcloud repo](http://github.com/neevtechnologies/visualcloud/).

2. **Write unit tests:** If you add or modify functionality, it must
   include unit tests. VisualCloud uses RSpec for its tests. If you are not an
   RSpec expert, if you let me know, I can help you write the specs.

3. **Update the `README`:** If the patch adds or modifies a major feature,
   modify the `README.md` file to reflect that. Again if you're not an
   expert with Markdown syntax, it's really easy to learn. Check out [Prose.io](http://prose.io/) to
   try it out.

4. **Push it:** Once you're ready, push your changes to a topic branch
   and add a note to the ticket with the URL to your branch. Or, say
   something like, "you can find the patch on johndoe/foobranch". I also
   gladly accept Github [pull requests](http://help.github.com/pull-requests/).

__NOTE:__ _We will take in whatever we can get._ If you prefer to
attach diffs in comments on issues, that's fine; but do know
that _someone_ will need to take the diff through the process described
above and this can hold things up considerably.


##License
Read the License [here](https://github.com/neevtechnologies/visualcloud/blob/master/LICENSE.txt)
