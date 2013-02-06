require 'spec_helper'

describe Environment do

  context "Validations" do
    subject { FactoryGirl.create(:environment) }
    it { should validate_presence_of  :name }
    #it { should validate_uniqueness_of(:deploy_order).scoped_to(:project_id) }
  end

  context "Associations" do
    it { should belong_to(:project) }
    it { should belong_to(:region) }
    it { should have_many(:instances) }
    let(:environment) {FactoryGirl.create(:environment)}
    let(:ec2_instance) {FactoryGirl.create(:ec2_instance,environment: environment)}
    let(:rds_instance) {FactoryGirl.create(:rds_instance,environment: environment)}
    it "should destroy associated instances" do
      instances = environment.instances
      UpdateProjectDataBagWorker.should_receive(:perform_async)      
      environment.destroy
      instances.should be_empty
    end
  end

  let(:project) {FactoryGirl.create(:project)}

  describe "#set_roles" do
    it "should invoke apply_roles on each of its instances" do
      environment = FactoryGirl.create(:environment)
      rds_instance = FactoryGirl.create(:rds_instance)
      ec2_instance = FactoryGirl.create(:ec2_instance)
      rds_instance.should_receive(:apply_roles)
      ec2_instance.should_receive(:apply_roles)
      environment.instances += [rds_instance, ec2_instance]
      environment.set_roles
    end
  end

  describe "#has_rds?" do
    let(:environment) {FactoryGirl.create(:environment)}
    it "should return true if the instance is rds" do
      resource_type = FactoryGirl.create(:resource_type)
      rds_instance = FactoryGirl.create(:rds_instance, resource_type: resource_type ,environment: environment)
      environment.has_rds?.should be_true
    end

    it "should return false if the instance is not rds" do
      resource_type = FactoryGirl.create(:resource_type , name: "Rails" ,resource_class: "EC2")
      ec2_instance = FactoryGirl.create(:ec2_instance, resource_type: resource_type ,environment: environment)
      environment.has_rds?.should be_false
    end
  end

  describe "#status" do
    let(:environment) {FactoryGirl.create(:environment)}
    let(:ec2_instance) {FactoryGirl.create(:ec2_instance, environment: environment)}
    let(:rds_instance) {FactoryGirl.create(:rds_instance, environment: environment)}
    it "should get the status of the environment" do
      aws_access_id = 'test_id'
      aws_secret_key = 'test_key'
      cloud = cloud_should_be_initialized(aws_access_id, aws_secret_key)
      cloud.should_receive(:status).with({stack_name: environment.aws_name}).and_return("CREATE_IN_PROGRESS")
      environment.status(aws_access_id,aws_secret_key).should == "CREATE_IN_PROGRESS"
    end

    it "should return nil when aws credentials are blank" do
      environment.status("","").should == nil
    end
  end


  describe "#get_rds_endpoints" do
    it "should get end points  for rds of the environment" do
      environment = FactoryGirl.create(:environment, aws_name: 'TestAwsLabel')
      ec2_instance = FactoryGirl.create(:ec2_instance, environment: environment)
      rds_instance = FactoryGirl.create(:rds_instance, environment: environment)
      aws_access_id = 'test_id'
      aws_secret_key = 'test_key'
      cloud = cloud_should_be_initialized(aws_access_id, aws_secret_key)
      result = [{:address => 'simcoprod01.cu7u2t4uz396.us-east-1.rds.amazonaws.com', :port => '3306'}]
      cloud.should_receive(:get_database_endpoints).with({stack_name: environment.aws_name}).and_return(result)
      environment.get_rds_endpoints(aws_access_id,aws_secret_key).should == result
    end
  end

  describe "#events" do
    it "should get events of the environment" do
      environment = FactoryGirl.create(:environment, aws_name: 'TestAwsLabel')
      ec2_instance = FactoryGirl.create(:ec2_instance, environment: environment)
      rds_instance = FactoryGirl.create(:rds_instance, environment: environment)
      aws_access_id = 'test_id'
      aws_secret_key = 'test_key'
      cloud = cloud_should_be_initialized(aws_access_id, aws_secret_key)
      result = {:key => 'one', :key2 => '3306'}
      cloud.should_receive(:events).with({stack_name: environment.aws_name}).and_return(result)
      environment.events(aws_access_id,aws_secret_key).should == result
    end

  end

  describe "#delete_stack" do
    it "should return true after delete the stack" do
      environment = FactoryGirl.create(:environment, aws_name: 'TestAwsLabel')
      ec2_instance = FactoryGirl.create(:ec2_instance, environment: environment)
      rds_instance = FactoryGirl.create(:rds_instance, environment: environment)
      aws_access_id = 'test_id'
      aws_secret_key = 'test_key'
      cloud = cloud_should_be_initialized(aws_access_id, aws_secret_key)
      cloud.should_receive(:delete).with({stack_name: environment.aws_name}).and_return(true)
      environment.delete_stack(aws_access_id,aws_secret_key).should == true
    end
  end


  context "provision with not having provisioned set for environment" do

    describe "#provision" do
      let(:region) { FactoryGirl.create(:region) }
      let(:ami) { FactoryGirl.create(:ami) }
      let(:environment) { FactoryGirl.create(:environment, region: region,name: 'TestAwsLabel')}
      let(:ec2_resource_type) { FactoryGirl.create(:resource_type , name: "Rails" ,resource_class: "EC2") }
      let(:instance_type) { FactoryGirl.create(:instance_type) }
      let(:ec2_instance){ FactoryGirl.create(:ec2_instance, label: "testec2",
          environment: environment, resource_type: ec2_resource_type,
          instance_type: instance_type,
          config_attributes: ({key1: 'value1', key2: 'value2', roles: ['app', 'java'],ami_id: ami.id}.to_json))}
      let(:rds_resource_type) { FactoryGirl.create(:resource_type , name: "RDS" ,resource_class: "RDS") }
      let(:rds_instance){ FactoryGirl.create(:rds_instance, label: "testrds",
          environment: environment, resource_type: rds_resource_type,
          instance_type: instance_type,
          config_attributes: ({size: '10', master_user_name: 'username', master_password: 'password',multiAZ: true}.to_json))}
      let(:s3_resource_type) { FactoryGirl.create(:resource_type , name: "S3" ,resource_class: "S3") }
      let(:s3_instance){ FactoryGirl.create(:s3_instance, label: "tests3",
          environment: environment, resource_type: s3_resource_type)}
      let(:elb_resource_type) { FactoryGirl.create(:resource_type , name: "ELB" ,resource_class: "ELB") }
      let(:elb_instance){ FactoryGirl.create(:elb_instance, label: "testelb",
          environment: environment, resource_type: elb_resource_type)}
      let(:elasticache_resource_type) { FactoryGirl.create(:resource_type , name: "ElastiCache" ,resource_class: "ElastiCache") }
      let(:elasticache_instance){ FactoryGirl.create(:elasticache_instance, label: "testsec",
          environment: environment, resource_type: elasticache_resource_type,
          instance_type: instance_type,
          config_attributes: ({key1: 'value1', key2: 'value2',cache_security_group_names: ['default'], node_count: 3}.to_json))}

      it "should call provision method" do
        environment.instances = [ec2_instance,rds_instance,s3_instance,elb_instance,elasticache_instance]
        stack_resources = []
        cloud = Cloudster::Cloud.new(access_key_id: 'test_id', secret_access_key: 'test_key', region: 'us-east-1')
        Cloudster::Cloud.should_receive(:new).with({:access_key_id => 'test_id', :secret_access_key => 'test_key', :region => 'us-east-1'}).and_return(cloud)
        environment.should_receive(:add_ec2_resources)
        environment.should_receive(:add_elb_resource)
        environment.should_receive(:add_rds_resources)
        environment.should_receive(:add_s3_resources)
        environment.should_receive(:add_elasticache_resources)
        cloud.should_receive(:provision).with({resources: stack_resources,stack_name: environment.aws_name, description: 'Provisioned by VisualCloud'})
        environment.provision('test_id', 'test_key')
      end

      it "should return true" do
        environment.instances = [ec2_instance,rds_instance,s3_instance,elb_instance,elasticache_instance]
        stack_resources = []
        cloud = Cloudster::Cloud.new(access_key_id: 'test_id', secret_access_key: 'test_key', region: 'us-east-1')
        Cloudster::Cloud.should_receive(:new).with({:access_key_id => 'test_id', :secret_access_key => 'test_key', :region => 'us-east-1'}).and_return(cloud)
        environment.should_receive(:add_ec2_resources)
        environment.should_receive(:add_elb_resource)
        environment.should_receive(:add_rds_resources)
        environment.should_receive(:add_s3_resources)
        environment.should_receive(:add_elasticache_resources)
        cloud.should_receive(:provision).with({resources: stack_resources,stack_name: environment.aws_name, description: 'Provisioned by VisualCloud'}).and_return(true)
        environment.provision('test_id', 'test_key').should == true
      end

      it "should set environment's provisioned attribute" do
        environment.instances = [ec2_instance,rds_instance,s3_instance,elb_instance,elasticache_instance]
        stack_resources = []
        cloud = Cloudster::Cloud.new(access_key_id: 'test_id', secret_access_key: 'test_key', region: 'us-east-1')
        Cloudster::Cloud.should_receive(:new).with({:access_key_id => 'test_id', :secret_access_key => 'test_key', :region => 'us-east-1'}).and_return(cloud)
        environment.should_receive(:add_ec2_resources)
        environment.should_receive(:add_elb_resource)
        environment.should_receive(:add_rds_resources)
        environment.should_receive(:add_s3_resources)
        environment.should_receive(:add_elasticache_resources)
        cloud.should_receive(:provision).with({resources: stack_resources,stack_name: environment.aws_name, description: 'Provisioned by VisualCloud'}).and_return(true)
        environment.provision('test_id', 'test_key')
        environment.provisioned.should == true
      end

    end
  end

  describe "#wait_till_provisioned" do      

    let(:environment) {FactoryGirl.create(:environment, aws_name: 'TestAwsLabel')}
    it "should have stack status to be CREATE_COMPLETE" do
      environment.should_receive(:status).with('test_id','test_key').and_return("CREATE_COMPLETE")
      environment.wait_till_provisioned('test_id','test_key',1)
      environment.provision_status.should == "CREATE_COMPLETE"
    end


    it "should return true for status is CREATE_COMPLETE" do
      environment.should_receive(:status).with('test_id','test_key').and_return("CREATE_COMPLETE")
      environment.wait_till_provisioned('test_id','test_key',1).should == true
    end

    it "should return false if status is not CREATE_COMPLETE" do
      environment.should_receive(:status).with('test_id','test_key').and_return("CREATE_INCOMPLETE")
      environment.wait_till_provisioned('test_id','test_key',1).should == false
    end
  end


  describe "#add_ec2_resources" do

    let(:region) { FactoryGirl.create(:region) }
    let(:ami) { FactoryGirl.create(:ami) }
    let(:environment) {FactoryGirl.create(:environment, aws_name: 'TestAwsLabel',
        region: region,
        key_pair_name: "default",
        security_group: "default" )}
    let(:resource_type) { FactoryGirl.create(:resource_type , name: "Rails" ,resource_class: "EC2") }
    let(:instance_type) { FactoryGirl.create(:instance_type) }
    let(:ec2_instance){ FactoryGirl.create(:ec2_instance, label: "testec2",
        environment: environment, resource_type: resource_type,
        instance_type: instance_type,
        config_attributes: ({key1: 'value1', key2: 'value2', roles: ['app', 'java'],ami_id: ami.id}.to_json))}
    before(:each) do
      input = {
        name: ec2_instance.aws_label,
        key_name: environment.key_pair_name,
        image_id: ec2_instance.ami.image(environment.send(:region_name)),
        security_groups: [environment.security_group],
        instance_type: ec2_instance.instance_type.api_name
      }
      @ec2 = Cloudster::Ec2.new(input)
      validation_key = File.should_receive(:read).with(VisualCloudConfig[:validation_key_path]).and_return("testkey")
      chef_client = Cloudster::ChefClient.new(validation_key: validation_key,
        server_url: "testurl",
        node_name: ec2_instance.id.to_s,
        interval: "20")
      chef_client.add_to @ec2
    end

    it "should return instances names" do
      instance_names = []
      stack_resources = []
      instance_names << ec2_instance.aws_label
      environment.add_ec2_resources(stack_resources).should == instance_names
    end

    it "should add the instance to stack" do
      instance_names = []
      stack_resources = []
      result_stack = stack_resources
      result_stack << @ec2
      environment.add_ec2_resources(stack_resources)
      stack_resources.should == result_stack
    end

    it "should add the instance to elasticip" do
      stack_resources = []
      elastic_ip = Cloudster::ElasticIp.new(name: "ElasticIp#{ec2_instance.aws_label}")
      elastic_ip.add_to @ec2
      result_stack = stack_resources
      result_stack << @ec2
      environment.add_ec2_resources(stack_resources)
      stack_resources.should == result_stack
    end

  end

  describe "#add_rds_resources" do

    let(:region) { FactoryGirl.create(:region) }
    let(:environment) {FactoryGirl.create(:environment, aws_name: 'TestAwsLabel',
        region: region,
        key_pair_name: "default",
        security_group: "default" )}
    let(:resource_type) { FactoryGirl.create(:resource_type) }
    let(:instance_type) { FactoryGirl.create(:instance_type) }
    let(:rds_instance){ FactoryGirl.create(:rds_instance, label: "testrds",
        environment: environment, resource_type: resource_type,
        instance_type: instance_type,
        config_attributes: ({size: '10', master_user_name: 'username', master_password: 'password',multiAZ: true}.to_json))}
    before(:each) do
      input = {
        name: rds_instance.aws_label,
        storage_size: rds_instance.config_attributes['size'],
        username: rds_instance.config_attributes['master_user_name'],
        password: rds_instance.config_attributes['master_password'],
        multi_az: rds_instance.config_attributes['multiAZ'],
        instance_class: rds_instance.instance_type.api_name
      }
      @rds = Cloudster::Rds.new(input)
    end

    it "should add the instance to stack" do
      stack_resources = []
      result_stack = stack_resources
      result_stack << @rds
      environment.add_rds_resources(stack_resources)
      stack_resources.should == result_stack
    end
  end

  describe "#add_s3_resources" do

    let(:region) { FactoryGirl.create(:region) }
    let(:environment) {FactoryGirl.create(:environment, aws_name: 'TestAwsLabel',
        region: region,
        key_pair_name: "default",
        security_group: "default" )}
    let(:resource_type) { FactoryGirl.create(:resource_type) }
    let(:instance_type) { FactoryGirl.create(:instance_type) }
    let(:s3_instance){ FactoryGirl.create(:s3_instance, label: "tests3",
        environment: environment, resource_type: resource_type)}
    before(:each) do
      input = {
        name: s3_instance.aws_label,
        access_control: s3_instance.config_attributes["access_control"]
      }
      @s3 = Cloudster::S3.new(input)
    end

    it "should add the instance to stack" do
      stack_resources = []
      result_stack = stack_resources
      result_stack << @s3
      environment.add_s3_resources(stack_resources)
      stack_resources.should == result_stack
    end

    it "should add the instance to cloudfront" do
      stack_resources = []
      cloud_front = Cloudster::CloudFront.new(:name => "CloudFront#{s3_instance.aws_label}")
      cloud_front.add_to(@s3)
      result_stack = stack_resources
      result_stack << @s3
      environment.add_s3_resources(stack_resources)
      stack_resources.should == result_stack
    end

  end

  describe "#add_elb_resources" do

    let(:region) { FactoryGirl.create(:region) }
    let(:environment) {FactoryGirl.create(:environment, aws_name: 'TestAwsLabel',
        region: region,
        key_pair_name: "default",
        security_group: "default" )}
    let(:resource_type1) { FactoryGirl.create(:resource_type,resource_class: "ELB") }
    let(:resource_type2) { FactoryGirl.create(:resource_type,resource_class: "RDS") }
    let(:instance_type) { FactoryGirl.create(:instance_type) }
    let(:elb_instance1){ FactoryGirl.create(:elb_instance, label: "testelb",
        environment: environment, resource_type: resource_type1)}
    let(:elb_instance2){ FactoryGirl.create(:elb_instance, label: "testelb",
        environment: environment, resource_type: resource_type2)}
    it "should add the instance to stack" do
      environment.instances = [elb_instance1]
      stack_resources = []
      instance_names = ['AppServer1','AppServer2']
      #instance_names = (instance_names & elb_instance1.children.collect(&:aws_label))
      input = {
        name: elb_instance1.aws_label,
        instance_names: instance_names,
        listeners: [
          {
            port: "300",
            instance_port: "200",
            protocol: "tcp"
          }
        ]
      }
      result_stack = stack_resources
      result_stack << Cloudster::Elb.new(input)
      environment.add_elb_resource(stack_resources,['AppServer1','AppServer2'])
      stack_resources.should == result_stack
    end

    it "should not add the instance to stack" do
      environment.instances = [elb_instance2]
      stack_resources = []
      environment.add_elb_resource(stack_resources,['AppServer1','AppServer2'])
      stack_resources.should == []
    end

  end

  describe "#add_elasticache_resources" do

    let(:region) { FactoryGirl.create(:region) }
    let(:environment) {FactoryGirl.create(:environment, aws_name: 'TestAwsLabel',
        region: region,
        key_pair_name: "default",
        security_group: "default" )}
    let(:resource_type_EC) { FactoryGirl.create(:resource_type,resource_class: "ElastiCache") }
    let(:resource_type_RDS) { FactoryGirl.create(:resource_type,resource_class: "RDS") }
    let(:instance_type) { FactoryGirl.create(:instance_type) }
    let(:elasticache_instance1){ FactoryGirl.create(:elasticache_instance, label: "testec",
        environment: environment, resource_type: resource_type_EC,
        instance_type: instance_type,
        config_attributes: ({key1: 'value1', key2: 'value2',cache_security_group_names: ['default'], node_count: 3}.to_json))}
    let(:elasticache_instance2){ FactoryGirl.create(:elasticache_instance, label: "testec",
        environment: environment, resource_type: resource_type_RDS,
        instance_type: instance_type,
        config_attributes: ({key1: 'value1', key2: 'value2',cache_security_group_names: ['default'], node_count: 3}.to_json))}
    it "should add the instance to stack" do
      environment.instances = [elasticache_instance1]
      stack_resources = []
      input = {
        name: elasticache_instance1.aws_label,
        node_type: elasticache_instance1.instance_type.api_name,
        cache_security_group_names: elasticache_instance1.config_attributes['cache_security_group_names'],
        engine: 'memcached',
        node_count: elasticache_instance1.config_attributes['node_count']
      }
      result_stack = stack_resources
      result_stack << Cloudster::ElastiCache.new(input)
      environment.add_elasticache_resources(stack_resources)
      stack_resources.should == result_stack
    end

    it "should not add the instance to stack" do
      environment.instances = [elasticache_instance2]
      stack_resources = []
      environment.add_elasticache_resources(stack_resources)
      stack_resources.should == []
    end

  end

  describe "#update_instance_outputs" do
    let(:resource_type_ec2) { FactoryGirl.create(:resource_type,resource_class: "EC2") }
    let(:resource_type_rds) { FactoryGirl.create(:resource_type,resource_class: "RDS") }
    it "should set the config attributes of all instances with the output values from stack" do
      environment = FactoryGirl.create(:environment, aws_name: 'TestAwsLabel')
      ec2_instance = FactoryGirl.create(:ec2_instance, environment: environment, resource_type: resource_type_ec2)
      rds_instance = FactoryGirl.create(:rds_instance, environment: environment, resource_type: resource_type_rds)
      environment.instances = [ec2_instance, rds_instance]
      aws_access_id = 'test_id'
      aws_secret_key = 'test_key'
      cloud = cloud_should_be_initialized(aws_access_id, aws_secret_key)
      cloud.should_receive(:outputs).with({stack_name: environment.aws_name}).and_return( {
          ec2_instance.aws_label => {
            'ip_address' => '42.42.42.42',
            'public_dns' => 'ec2.public.dns',
          },
          rds_instance.aws_label => {
            'ip_address' => '52.52.52.52',
            'port' => '1234'
          }
        })
      ec2_instance_existing_attributes = JSON.parse(ec2_instance.config_attributes)
      rds_instance_existing_attributes = JSON.parse(rds_instance.config_attributes)

      environment.update_instance_outputs(aws_access_id, aws_secret_key)
      ec2_instance.reload
      rds_instance.reload
      ec2_instance.config_attributes.should == ec2_instance_existing_attributes.merge({
          ip_address: '42.42.42.42',
          public_dns: 'ec2.public.dns'
        }).to_json
      rds_instance.config_attributes.should == rds_instance_existing_attributes.merge({
          ip_address: '52.52.52.52',
          port: '1234'
        }).to_json
    end
  end

end
