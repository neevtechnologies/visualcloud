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
ResourceType.create(resource_class: 'ELB', name: 'ELB', parents_list: "" , small_icon: "amazon/AWS_Simple_Icons_Networking_Amazon_Elastic_Load_Balancer.svg", large_icon: "amazon/AWS_Simple_Icons_Networking_Amazon_Elastic_Load_Balancer.svg", description: 'Elastic Load Balancer')
ResourceType.create(resource_class: 'EC2', name: 'EC2', parents_list: "ELB,Nginx" , small_icon: "amazon/AWS_Simple_Icons_Compute_Amazon_EC2.svg", large_icon: "amazon/AWS_Simple_Icons_Compute_Amazon_EC2.svg", description: 'Elastic Cloud Compute')
ResourceType.create(resource_class: 'RDS', name: 'RDS', parents_list: "Rails,JAVA,PHP" , small_icon: "amazon/AWS_Simple_Icons_Database_Amazon_RDS.svg", large_icon: "amazon/AWS_Simple_Icons_Database_Amazon_RDS.svg", description: 'Relational Database Service')
ResourceType.create(resource_class: 'EC2', name: 'Rails', parents_list: "ELB,Nginx" , small_icon: "components/rails.png", large_icon: "components/rails.png" , description: 'Rails hosting instance running Unicorn as Application Server')
ResourceType.create(resource_class: 'EC2', name: 'Mysql', parents_list: "Rails,JAVA,PHP" , small_icon: "components/mysql.png", large_icon: "components/mysql.png", description: 'MySQL database server')
ResourceType.create(resource_class: 'EC2', name: 'Nginx', parents_list: "ELB" , small_icon: "components/nginx.png", large_icon: "components/nginx.png", description: 'Nginx LoadBalancer for your application servers')
ResourceType.create(resource_class: 'EC2', name: 'JAVA', parents_list: "ELB,Nginx" , small_icon: "components/java.png", large_icon: "components/java.png", description: 'JAVA your application server')
ResourceType.create(resource_class: 'EC2', name: 'PHP', parents_list: "ELB,Nginx" , small_icon: "components/php.png", large_icon: "components/php.png", description: 'PHP your application server')

#Components
Component.create(name: 'Rails', small_icon: "components/rails.svg", large_icon: "components/rails.svg")
Component.create(name: 'PHP', small_icon: "components/php.svg", large_icon: "components/php.svg")

#Ami'S
Ami.create(image_id:'ami-0a79db63', architecture:'x86_64', name:'EA-AppServer', description:'Ubuntu 12.04 + Ruby 1.9.3 p194')

#Instance Types for ec2
InstanceType.create(api_name: 'm1.small', name:'Small', size:'1.7 GB')
InstanceType.create(api_name: 'm1.medium', name:'Medium', size:'3.75 GB')
InstanceType.create(api_name: 'm1.large', name:'Large', size:'7.5 GB')
InstanceType.create(api_name: 'm1.xlarge', name:'Extra Large', size:'15 GB')
InstanceType.create(api_name: 't1.micro', name:'Micro', size:'613 MB')
InstanceType.create(api_name: 'm2.xlarge', name:'High-Memory Extra Large', size:'17.1 GB')
InstanceType.create(api_name: 'm2.2xlarge', name:'High-Memory Double Extra Large', size:'34.2 GB')
InstanceType.create(api_name: 'm2.4xlarge', name:'High-Memory Quadruple Extra Large', size:'68.4 GB')
InstanceType.create(api_name: 'c1.meidum', name:'High-CPU Medium', size:'1.7 GB')
InstanceType.create(api_name: 'c1.xlarge', name:'High-CPU Extra Large', size:'7 GB')
InstanceType.create(api_name: 'cc1.4xlarge', name:'Cluster Compute Quadruple Extra Large', size:'23 GB')
InstanceType.create(api_name: 'cc2.8xlarge', name:'Cluster Compute Eight Extra Large', size:'60.5 GB')
InstanceType.create(api_name: 'cg1.4xlarge', name:'Cluster GPU Quadruple Extra Large', size:'22 GB')
InstanceType.create(api_name: 'hi1.4xlarge', name:'High I/O Quadruple Extra Large', size:'60.5 GB')

ec2 = ResourceType.find_by_name('EC2')
InstanceType.all.each do |p|
  p.update_attribute(:resource_type_id,ec2.id)
end

#Instance Types for rds
rds = ResourceType.find_by_name('RDS')
InstanceType.create(api_name: 'db.t1.micro', name:'Micro', size:'',resource_type_id:rds.id)
InstanceType.create(api_name: 'db.m1.small', name:'Small', size:'',resource_type_id:rds.id)
InstanceType.create(api_name: 'db.m1.large', name:'Large', size:'',resource_type_id:rds.id)
InstanceType.create(api_name: 'db.m1.xlarge', name:'Extra Large', size:'',resource_type_id:rds.id)
InstanceType.create(api_name: 'db.m2.xlarge', name:'High-Memory Extra Large', size:'',resource_type_id:rds.id)
InstanceType.create(api_name: 'db.m2.2xlarge', name:'High-Memory Double Extra Large', size:'',resource_type_id:rds.id)
InstanceType.create(api_name: 'db.m2.4xlarge', name:'High-Memory Quadruple Extra Large', size:'',resource_type_id:rds.id)
