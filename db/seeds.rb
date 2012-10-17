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
ResourceType.create(name: 'ELB', small_icon: "amazon/AWS_Simple_Icons_Networking_Amazon_Elastic_Load_Balancer.svg", large_icon: "amazon/AWS_Simple_Icons_Networking_Amazon_Elastic_Load_Balancer.svg")
ResourceType.create(name: 'EC2', small_icon: "amazon/AWS_Simple_Icons_Compute_Amazon_EC2.svg", large_icon: "amazon/AWS_Simple_Icons_Compute_Amazon_EC2.svg")
ResourceType.create(name: 'RDS', small_icon: "amazon/AWS_Simple_Icons_Database_Amazon_RDS.svg", large_icon: "amazon/AWS_Simple_Icons_Database_Amazon_RDS.svg")

#Components
Component.create(name: 'Rails', small_icon: "components/rails.svg", large_icon: "components/rails.svg")
Component.create(name: 'PHP', small_icon: "components/php.svg", large_icon: "components/php.svg")

#Ami'S
Ami.create(image_id:'ami-0a79db63', architecture:'x86_64', name:'EA-AppServer', description:'Ubuntu 12.04 + Ruby 1.9.3 p194')

#Instance Types
InstanceType.create(name:'Small', size:'1.7 GB')
InstanceType.create(name:'Medium', size:'3.75 GB')
InstanceType.create(name:'Large', size:'7.5 GB')
InstanceType.create(name:'Extra Large', size:'15 GB')
InstanceType.create(name:'Micro', size:'613 MB')
InstanceType.create(name:'High-Memory Extra Large', size:'17.1 GB')
InstanceType.create(name:'High-Memory Double Extra Large', size:'34.2 GB')
InstanceType.create(name:'High-Memory Quadruple Extra Large', size:'68.4 GB')
InstanceType.create(name:'High-CPU Medium', size:'1.7 GB')
InstanceType.create(name:'High-CPU Extra Large', size:'7 GB')
InstanceType.create(name:'Cluster Compute Quadruple Extra Large', size:'23 GB')
InstanceType.create(name:'Cluster Compute Eight Extra Large', size:'60.5 GB')
InstanceType.create(name:'Cluster GPU Quadruple Extra Large', size:'22 GB')
InstanceType.create(name:'High I/O Quadruple Extra Large', size:'60.5 GB')
