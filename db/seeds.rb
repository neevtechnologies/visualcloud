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

#Regions
Region.create latitude: 38.597626, longitude: -80.454903, display_name: 'US East - N.Virginia', name: 'us-east-1'
Region.create latitude: 43.804133, longitude: -120.554201, display_name: 'US West - Oregon', name: 'us-west-2'
Region.create latitude: 36.778261, longitude: -119.417932, display_name: 'US West - N.California', name: 'us-west-1'
Region.create latitude: 53.41291, longitude: -8.24389, display_name: 'EU - Ireland', name: 'eu-west-1'
Region.create latitude: 1.352083, longitude: 103.819836, display_name: 'Asia Pacific - Singapore', name: 'ap-southeast-1'
Region.create latitude: 35.689488, longitude: 139.691706, display_name: 'Asia Pacific - Tokyo', name: 'ap-northeast-1'
Region.create latitude: -33.867487, longitude: 151.20699, display_name: 'Asia Pacific - Sydney', name: 'ap-southeast-2'
Region.create latitude: -23.548943, longitude: -46.638818, display_name: 'South America - Sao Paulo', name: 'sa-east-1'

#ResourceTypes
#AWS native resources
ResourceType.create(resource_class: 'ELB', name: 'ELB', parents_list: "" , small_icon: "components/elb.png", large_icon: "components/elb.png", description: 'Elastic Load Balancer')
ResourceType.create(resource_class: 'EC2', name: 'EC2', parents_list: "ELB,Nginx" , small_icon: "amazon/AWS_Simple_Icons_Compute_Amazon_EC2.svg", large_icon: "amazon/AWS_Simple_Icons_Compute_Amazon_EC2.svg", description: 'Elastic Cloud Compute')
ResourceType.create(resource_class: 'RDS', name: 'RDS', parents_list: "Rails,Java,PHP" , small_icon: "components/rds.png", large_icon: "components/rds.png", description: 'Relational Database Service')

#EC2 Type resources
ResourceType.create(resource_class: 'EC2', name: 'Rails', parents_list: "ELB,Nginx" , small_icon: "components/rails.png", large_icon: "components/rails.png" , description: 'Rails hosting instance running Unicorn as Application Server', roles: ['app', 'rails'].to_json)
ResourceType.create(resource_class: 'EC2', name: 'Mysql', parents_list: "Rails,Java,PHP" , small_icon: "components/mysql.png", large_icon: "components/mysql.png", description: 'MySQL database server', roles: ['db', 'mysql'].to_json)
ResourceType.create(resource_class: 'EC2', name: 'Nginx', parents_list: "ELB" , small_icon: "components/nginx.png", large_icon: "components/nginx.png", description: 'Nginx LoadBalancer for your application servers', roles: ['nginx'].to_json)
ResourceType.create(resource_class: 'EC2', name: 'Java', parents_list: "ELB,Nginx" , small_icon: "components/java.png", large_icon: "components/java.png", description: 'Java application server', roles: ['app', 'java'].to_json)
ResourceType.create(resource_class: 'EC2', name: 'PHP', parents_list: "ELB,Nginx" , small_icon: "components/php.png", large_icon: "components/php.png", description: 'PHP application server', roles: ['app', 'php'].to_json)

#Ami'S
Ami.create(image_id:'ami-0a79db63', architecture:'x86_64', name:'EA-AppServer', description:'Ubuntu 12.04 + Ruby 1.9.3 p194')

#Instance Types for ec2
ec2_instance_types = []
ec2_instance_types << InstanceType.create(api_name: 'm1.small', name:'Small', size:'1.7 GB',description: '1.7 GiB memory,1 EC2 Compute Unit (1 virtual core with 1 EC2 Compute Unit),160 GB instance storage,32-bit or 64-bit platform,I/O Performance: Moderate,EBS-Optimized Available: No',label:'S')
ec2_instance_types << InstanceType.create(api_name: 'm1.medium', name:'Medium', size:'3.75 GB',description: '3.75 GiB memory,2 EC2 Compute Unit (1 virtual core with 2 EC2 Compute Unit),410 GB instance storage,32-bit or 64-bit platform,I/O Performance: Moderate,EBS-Optimized Available: No',label:'M')
ec2_instance_types << InstanceType.create(api_name: 'm1.large', name:'Large', size:'7.5 GB',description: '7.5 GiB memory,4 EC2 Compute Units (2 virtual cores with 2 EC2 Compute Units each),850 GB instance storage,64-bit platform,I/O Performance: High,EBS-Optimized Available: 500 Mbps',label:'L')
ec2_instance_types << InstanceType.create(api_name: 'm1.xlarge', name:'Extra Large', size:'15 GB',description: '15 GiB memory,8 EC2 Compute Units (4 virtual cores with 2 EC2 Compute Units each),1,690 GB instance storage,64-bit platform,I/O Performance: High,EBS-Optimized Available: 1000 Mbps',label:'X')
ec2_instance_types << InstanceType.create(api_name: 't1.micro', name:'Micro', size:'613 MB',description: '613 MiB memory,Up to 2 EC2 Compute Units (for short periodic bursts),EBS storage only,32-bit or 64-bit platform,I/O Performance: Low,EBS-Optimized Available: No',label:'Mi')
ec2_instance_types << InstanceType.create(api_name: 'm2.xlarge', name:'High-Memory Extra Large', size:'17.1 GB',description: '17.1 GiB of memory,6.5 EC2 Compute Units (2 virtual cores with 3.25 EC2 Compute Units each),420 GB of instance storage,64-bit platform,I/O Performance: Moderate,EBS-Optimized Available: No',label:'MX')
ec2_instance_types << InstanceType.create(api_name: 'm2.2xlarge', name:'High-Memory Double Extra Large', size:'34.2 GB',description: '34.2 GiB of memory,13 EC2 Compute Units (4 virtual cores with 3.25 EC2 Compute Units each),850 GB of instance storage,64-bit platform,I/O Performance: High,EBS-Optimized Available: No',label:'MDX')
ec2_instance_types << InstanceType.create(api_name: 'm2.4xlarge', name:'High-Memory Quadruple Extra Large', size:'68.4 GB',description: '68.4 GiB of memory,26 EC2 Compute Units (8 virtual cores with 3.25 EC2 Compute Units each),1690 GB of instance storage,64-bit platform,I/O Performance: High,EBS-Optimized Available: 1000 Mbps',label:'MQX')
ec2_instance_types << InstanceType.create(api_name: 'c1.meidum', name:'High-CPU Medium', size:'1.7 GB',description: '1.7 GiB of memory,5 EC2 Compute Units (2 virtual cores with 2.5 EC2 Compute Units each),350 GB of instance storage,32-bit or 64-bit platform,I/O Performance: Moderate,EBS-Optimized Available: No',label:'CM')
ec2_instance_types << InstanceType.create(api_name: 'c1.xlarge', name:'High-CPU Extra Large', size:'7 GB',description: '7 GiB of memory,20 EC2 Compute Units (8 virtual cores with 2.5 EC2 Compute Units each),1690 GB of instance storage,64-bit platform,I/O Performance: High,EBS-Optimized Available: No',label:'CX')
ec2_instance_types << InstanceType.create(api_name: 'cc1.4xlarge', name:'Cluster Compute Quadruple Extra Large', size:'23 GB',description: '23 GiB of memory,33.5 EC2 Compute Units (2 x Intel Xeon X5570, quad-core Nehalem architecture),1690 GB of instance storage,64-bit platform,I/O Performance: Very High (10 Gigabit Ethernet)',label:'CCQ')
ec2_instance_types << InstanceType.create(api_name: 'cc2.8xlarge', name:'Cluster Compute Eight Extra Large', size:'60.5 GB',description: '60.5 GiB of memory,88 EC2 Compute Units (2 x Intel Xeon E5-2670, eight-core Sandy Bridge architecture),3370 GB of instance storage,64-bit platform,I/O Performance: Very High (10 Gigabit Ethernet)',label:'CC8')
ec2_instance_types << InstanceType.create(api_name: 'cg1.4xlarge', name:'Cluster GPU Quadruple Extra Large', size:'22 GB',description: '22 GiB of memory,33.5 EC2 Compute Units (2 x Intel Xeon X5570, quad-core Nehalem architecture),2 x NVIDIA Tesla Fermi M2050 GPUs,1690 GB of instance storage,64-bit platform,I/O Performance: Very High (10 Gigabit Ethernet)',label:'CGQ')
ec2_instance_types << InstanceType.create(api_name: 'hi1.4xlarge', name:'High I/O Quadruple Extra Large', size:'60.5 GB',description: '60.5 GiB of memory,35 EC2 Compute Units (16 virtual cores [8 cores + 8 hyperthreads]),2 SSD-based volumes each with 1024 GB of instance storage,64-bit platform,I/O Performance: Very High (10 Gigabit Ethernet)',label:'IOQ')

ec2 = ResourceType.find_by_name('EC2')
ec2.instance_types = ec2_instance_types
ec2.save

#Instance Types for rds
rds = ResourceType.find_by_name('RDS')
InstanceType.create(api_name: 'db.t1.micro', name:'Micro', size:'',resource_type_id:rds.id,description: '630 MB memory, Up to 2 ECU (for short periodic bursts), 64-bit platform, Low I/O Capacity',label:'DMi')
InstanceType.create(api_name: 'db.m1.small', name:'Small', size:'',resource_type_id:rds.id,description: '1.7 GB memory, 1 ECU (1 virtual core with 1 ECU), 64-bit platform, Moderate I/O Capacity',label:'DS')
InstanceType.create(api_name: 'db.m1.large', name:'Large', size:'',resource_type_id:rds.id,description: '7.5 GB memory, 4 ECUs (2 virtual cores with 2 ECUs each), 64-bit platform, High I/O Capacity',label:'DL')
InstanceType.create(api_name: 'db.m1.xlarge', name:'Extra Large', size:'',resource_type_id:rds.id,description: '15 GB of memory, 8 ECUs (4 virtual cores with 2 ECUs each), 64-bit platform, High I/O Capacity',label:'DX')
InstanceType.create(api_name: 'db.m2.xlarge', name:'High-Memory Extra Large', size:'',resource_type_id:rds.id,description: '17.1 GB memory, 6.5 ECU (2 virtual cores with 3.25 ECUs each), 64-bit platform, High I/O Capacity',label:'DMX')
InstanceType.create(api_name: 'db.m2.2xlarge', name:'High-Memory Double Extra Large', size:'',resource_type_id:rds.id,description: '34 GB of memory, 13 ECUs (4 virtual cores with 3,25 ECUs each), 64-bit platform, High I/O Capacity',label:'DMD')
InstanceType.create(api_name: 'db.m2.4xlarge', name:'High-Memory Quadruple Extra Large', size:'',resource_type_id:rds.id,description: '68 GB of memory, 26 ECUs (8 virtual cores with 3.25 ECUs each), 64-bit platform, High I/O Capacity',label:'DMQ')
