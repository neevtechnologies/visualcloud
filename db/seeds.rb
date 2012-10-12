# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

#Users
user = User.create! :name => 'First User', :email => 'user@example.com', :password => 'password', :password_confirmation => 'password'
user2 = User.create! :name => 'Second User', :email => 'user2@example.com', :password => 'please', :password_confirmation => 'please'
user.add_role :admin

#ResourceTypes
ResourceType.create(name: 'EC2', small_icon: "amazon/AWS_Simple_Icons_Compute_Amazon_EC2.svg", large_icon: "amazon/AWS_Simple_Icons_Compute_Amazon_EC2.svg")
ResourceType.create(name: 'RDS', small_icon: "amazon/AWS_Simple_Icons_Database_Amazon_RDS.svg", large_icon: "amazon/AWS_Simple_Icons_Database_Amazon_RDS.svg")

#Ami'S
Ami.create(image_id:'ami-0a79db63', architecture:'x86_64', name:'EA-AppServer', description:'Ubuntu 12.04 + Ruby 1.9.3 p194')
