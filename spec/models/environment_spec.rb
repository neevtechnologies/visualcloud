require 'spec_helper'

describe Environment do

  context "Validations" do
    subject { FactoryGirl.create(:environment) }
    it { should validate_presence_of  :name }
    it { should validate_uniqueness_of(:deploy_order).scoped_to(:project_id) }
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

  describe "#provision" do

#    it "should return true after provision the environment" do
#      environment = FactoryGirl.create(:environment, aws_name: 'TestAwsLabel', provisioned: true)
#      ec2_instance = FactoryGirl.create(:ec2_instance, environment: environment)
#      rds_instance = FactoryGirl.create(:rds_instance, environment: environment)
#      aws_access_id = 'test_id'
#      aws_secret_key = 'test_key'
#      cloud = cloud_should_be_initialized(aws_access_id, aws_secret_key)
#      result = [{},{}]
#      if environment.provisioned
#        cloud.should_receive(:update).with({resources: result,stack_name: environment.aws_name, description: 'Updated by VisualCloud'}).and_return(true)
#      else
#        cloud.should_receive(:provision).with({resources: result,stack_name: environment.aws_name, description: 'Provisioned by VisualCloud'}).and_return(true)
#      end
#      environment.provision.should == true
#    end

  end

  describe "#add_ec2_resources" do

    it "should return instances names" do
      instance_names = []
      region = FactoryGirl.create(:region)
      ami = FactoryGirl.create(:ami)
      environment = FactoryGirl.create(:environment, aws_name: 'TestAwsLabel', region: region, key_pair_name: "default", security_group: "default" )
      resource_type = FactoryGirl.create(:resource_type , name: "Rails" ,resource_class: "EC2")
      instance_type = FactoryGirl.create(:instance_type)
      ec2_instance = FactoryGirl.create(:ec2_instance,
        aws_label: "testec2",
        environment: environment,
        resource_type: resource_type,
        instance_type: instance_type,
        config_attributes: ({key1: 'value1', key2: 'value2', roles: ['app', 'java'],ami_id: ami.id}.to_json))
      key_pair = environment.key_pair_name.blank? ? 'default' : environment.key_pair_name
      security_groups = (environment.security_group.to_s.strip.split(/\s*,\s*/).blank? ? ['default'] : environment.security_group.to_s.strip.split(/\s*,\s*/))
      ec2_instance.reload
      input = {
        name: ec2_instance.aws_label,
        key_name: key_pair,
        image_id: ec2_instance.ami.image(environment.send(:region_name)),
        security_groups: security_groups,
        instance_type: ec2_instance.instance_type.api_name
      }
      ec2 = Cloudster::Ec2.new(input)
      validation_key = File.should_receive(:read).and_return("testkey")
      chef_client = Cloudster::ChefClient.new(validation_key: validation_key,
          server_url: "testurl",
          node_name: ec2_instance.id.to_s,
          interval: "20")
      chef_client.add_to ec2
      instance_names << ec2_instance.aws_label
      stack_resources = []
      environment.add_ec2_resources(stack_resources).should == instance_names
    end

    it "should add the instance to stack" do
      #environment.add_ec2_resources(stack_resources)
      #stack_resources.should == ec2
    end
  end

  describe "#update_instance_outputs" do
    it "should set the config attributes of all instances with the output values from stack" do
      environment = FactoryGirl.create(:environment, aws_name: 'TestAwsLabel')
      ec2_instance = FactoryGirl.create(:ec2_instance, environment: environment)
      rds_instance = FactoryGirl.create(:rds_instance, environment: environment)
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
