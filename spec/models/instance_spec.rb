require 'spec_helper'

describe Instance do

  context "Validations" do
    subject { FactoryGirl.create(:ec2_instance) }

    it { should validate_presence_of(:label) }
    it { should validate_numericality_of(:xpos) }
    it { should validate_numericality_of(:ypos) }
    it { should validate_uniqueness_of(:label).scoped_to(:environment_id) }
  end

  context "Associations" do
    it { should belong_to(:environment) }
    it { should belong_to(:resource_type) }
    it { should belong_to(:instance_type) }
    #    it { should have_many(:parents).through(:parent_child_relationships).source(:parent) }
    #    it { should have_many(:children).through(:parent_child_relationships).source(:child) }
    #    it { should have_many(:parent_child_relationships).class("InstanceRelationship").foreign_key(:child_id) }
    #    it { should have_many(:child_parent_relationships).class("InstanceRelationship").foreign_key(:parent_id) }
  end


  describe "#wait_till_started" do

    let(:environment) { FactoryGirl.create(:environment, aws_name: 'TestAwsLabel') }
    let(:ec2_instance) { FactoryGirl.create(:ec2_instance, instance_status: '') }

    before :each do
      environment.instances = [ec2_instance]
    end

    it "should return true if instance started" do
      ec2_instance.should_receive(:get_instance_status).and_return("running")
      ec2_instance.wait_till_started("test_id","test_key",1).should == true
    end

    it "should return false if instance is not started" do
      ec2_instance.should_receive(:get_instance_status).and_return("stopped")
      ec2_instance.wait_till_started("test_id","test_key",1).should == false
    end

  end

  describe "#wait_till_stopped" do

    let(:environment) { FactoryGirl.create(:environment, aws_name: 'TestAwsLabel') }
    let(:ec2_instance) { FactoryGirl.create(:ec2_instance, instance_status: '') }

    before :each do
      environment.instances = [ec2_instance]
    end

    it "should return true if instance stopped" do
      ec2_instance.should_receive(:get_instance_status).and_return("stopped")
      ec2_instance.wait_till_stopped("test_id","test_key",1).should == true
    end

    it "should return false if instance is not stopped" do
      ec2_instance.should_receive(:get_instance_status).and_return("running")
      ec2_instance.wait_till_stopped("test_id","test_key",1).should == false
    end

  end

  describe "#get_instance_status" do
    let(:environment) { FactoryGirl.create(:environment, aws_name: 'TestAwsLabel') }
    let(:ec2_instance) { FactoryGirl.create(:ec2_instance, instance_status: '') }

    before :each do
      environment.instances = [ec2_instance]
    end

    it "should return instance status as running" do
      cloud = Cloudster::Cloud.new(access_key_id: 'test_id', secret_access_key: 'test_key')
      Cloudster::Cloud.should_receive(:new).with({:access_key_id => 'test_id', :secret_access_key => 'test_key'}).and_return(cloud)
      cloud.should_receive(:get_ec2_details).with({stack_name: ec2_instance.environment.aws_name}).and_return({ec2_instance.aws_label => {"privateIpAddress" => "10.0.5.134", "instanceState" => {"name" => "running"}}})
      ec2_instance.get_instance_status("test_id","test_key").should == "running"
    end

    it "should return instance status as stopped" do
      cloud = Cloudster::Cloud.new(access_key_id: 'test_id', secret_access_key: 'test_key')
      Cloudster::Cloud.should_receive(:new).with({:access_key_id => 'test_id', :secret_access_key => 'test_key'}).and_return(cloud)
      cloud.should_receive(:get_ec2_details).with({stack_name: ec2_instance.environment.aws_name}).and_return({ec2_instance.aws_label => {"privateIpAddress" => "10.0.5.134", "instanceState" => {"name" => "stopped"}}})
      ec2_instance.get_instance_status("test_id","test_key").should == "stopped"
    end
  end


  describe "#update_status_and_config_attributes" do
    let(:environment) { FactoryGirl.create(:environment, aws_name: 'TestAwsLabel') }
    let(:ec2_instance) { FactoryGirl.create(:ec2_instance, instance_status: '') }

    before :each do
      environment.instances = [ec2_instance]
    end

    it "should update the config attributes while stopping the instance" do
      ec2_instance.should_receive(:get_new_config_attributes).and_return({"private_ip" => "", "public_ip" => "", "private_dns_name" => "", "public_dns_name" => ""})
      existing_config_attributes = JSON.parse(ec2_instance.config_attributes)
      ec2_instance.update_status_and_config_attributes("stop","test_id","test_key")
      ec2_instance.config_attributes.should == existing_config_attributes.merge({"private_ip" => "", "public_ip" => "", "private_dns_name" => "", "public_dns_name" => ""}).to_json
    end

    it "should update the config attributes while starting the instance" do
      ec2_instance.should_receive(:get_new_config_attributes).and_return({"private_ip" => "10.2.3.11", "public_ip" => "11.2.3.12", "private_dns_name" => "abc@ec2.com", "public_dns_name" => "abc@ec2_in.com"})
      existing_config_attributes = JSON.parse(ec2_instance.config_attributes)
      ec2_instance.update_status_and_config_attributes("start","test_id","test_key")
      ec2_instance.config_attributes.should == existing_config_attributes.merge({"private_ip" => "10.2.3.11", "public_ip" => "11.2.3.12", "private_dns_name" => "abc@ec2.com", "public_dns_name" => "abc@ec2_in.com"}).to_json
    end

    it "should update the instance status to stopped" do
      ec2_instance.should_receive(:get_new_config_attributes).and_return({"private_ip" => "", "public_ip" => "", "private_dns_name" => "", "public_dns_name" => ""})
      ec2_instance.update_status_and_config_attributes("stop","test_id","test_key")
      ec2_instance.instance_status.should == "stopped"
    end

    it "should update the instance status to stopped" do
      ec2_instance.should_receive(:get_new_config_attributes).and_return({"private_ip" => "10.2.3.11", "public_ip" => "11.2.3.12", "private_dns_name" => "abc@ec2.com", "public_dns_name" => "abc@ec2_in.com"})
      ec2_instance.update_status_and_config_attributes("start","test_id","test_key")
      ec2_instance.instance_status.should == "running"
    end
  end

  describe "#get_new_config_attributes" do
    let(:environment) { FactoryGirl.create(:environment, aws_name: 'TestAwsLabel') }
    let(:ec2_instance) { FactoryGirl.create(:ec2_instance, instance_status: '') }

    before :each do
      environment.instances = [ec2_instance]
    end

    it "should get filled values for private ip, public ip in config attributes if task is start" do
      cloud = Cloudster::Cloud.new(access_key_id: 'test_id', secret_access_key: 'test_key')
      Cloudster::Cloud.should_receive(:new).with({:access_key_id => 'test_id', :secret_access_key => 'test_key'}).and_return(cloud)
      cloud.should_receive(:get_ec2_details).with({stack_name: ec2_instance.environment.aws_name}).and_return({ec2_instance.aws_label => {"privateIpAddress" => "10.0.5.134", "ipAddress" => "12.1.2.200", "privateDnsName" => "abc@ec.com", "dnsName" => "abc@ec21.com"}})
      ec2_instance.get_new_config_attributes("start","test_id","test_key").should == {"private_ip" => "10.0.5.134","public_ip" => "12.1.2.200","private_dns_name" => "abc@ec.com","public_dns_name" => "abc@ec21.com"}
    end

    it "should get empty values for private ip, public ip in config attributes if task is stop" do
      cloud = Cloudster::Cloud.new(access_key_id: 'test_id', secret_access_key: 'test_key')
      Cloudster::Cloud.should_receive(:new).with({:access_key_id => 'test_id', :secret_access_key => 'test_key'}).and_return(cloud)
      cloud.should_receive(:get_ec2_details).with({stack_name: ec2_instance.environment.aws_name}).and_return({ec2_instance.aws_label => {"privateIpAddress" => "", "ipAddress" => "", "privateDnsName" => "", "dnsName" => ""}})
      ec2_instance.get_new_config_attributes("stop","test_id","test_key").should == {"private_ip" => "","public_ip" => "","private_dns_name" => "","public_dns_name" => ""}
    end
  end

  describe "#check_status_of_ec2_element" do

    let(:environment) { FactoryGirl.create(:environment, aws_name: 'TestAwsLabel', provision_status: '') }
    let(:ec2_instance) { FactoryGirl.create(:ec2_instance, instance_status: '') }

    before :each do
      environment.instances = [ec2_instance]
    end

    it "should return false if instance environment provision_status is not CREATE_COMPLETE or UPDATE_COMPLETE" do
      ec2_instance.check_status_of_ec2_element("running").should == false
    end

    it "should return false if instance_status of the element is running" do
      ec2_instance.environment.provision_status = 'CREATE_COMPLETE'
      ec2_instance.instance_status = 'running'
      ec2_instance.check_status_of_ec2_element("running").should == false
    end

    it "should return true if instance_status of the element is not stopped" do
      ec2_instance.environment.provision_status = 'CREATE_COMPLETE'
      ec2_instance.instance_status = 'stopped'
      ec2_instance.check_status_of_ec2_element("running").should == true
    end

  end

  describe "#ami" do

    it "should invoke ami for instance" do
      ami = FactoryGirl.create(:ami)
      ec2_instance = FactoryGirl.create(:ec2_instance , config_attributes:{ami_id: ami.id}.to_json)
      ec2_instance.ami.should == ami
    end

    it "should return nil, when invoked ami for instance if ami_id is not present" do
      ec2_instance = FactoryGirl.create(:ec2_instance)
      ec2_instance.ami.should == nil
    end

  end

  describe "#apply_roles" do

    it "should invoke add_role on instance" do
      ec2_instance = FactoryGirl.create(:ec2_instance)
      attributes = JSON.parse(ec2_instance.config_attributes)
      ec2_instance.should_receive(:add_role).with(ec2_instance.id,attributes['roles'])
      ec2_instance.apply_roles
    end
  end

  describe "#update_output" do
    let(:resource_type_ec2) { FactoryGirl.create(:resource_type,resource_class: "EC2") }
    let(:resource_type_rds) { FactoryGirl.create(:resource_type,resource_class: "RDS") }
    it "should set the config attributes of an instance with the output values from stack" do
      ec2_instance = FactoryGirl.create(:ec2_instance , resource_type: resource_type_ec2)
      existing_config_attributes = JSON.parse(ec2_instance.config_attributes)
      ec2_instance.should_receive(:add_elastic_ip).with({},{ip_address: '42.42.42.42',public_dns: 'ec2.public.dns'})
      ec2_instance.update_output({},{ip_address: '42.42.42.42',public_dns: 'ec2.public.dns'})
      ec2_instance.reload
      ec2_instance.config_attributes.should == existing_config_attributes.merge({
          ip_address: '42.42.42.42',
          public_dns: 'ec2.public.dns'
        }).to_json
    end

    it "should invoke add_elastic_ip for ec2 instance type" do
      ec2_instance = FactoryGirl.create(:ec2_instance , resource_type: resource_type_ec2)
      existing_config_attributes = JSON.parse(ec2_instance.config_attributes)
      ec2_instance.should_receive(:add_elastic_ip)
      ec2_instance.update_output({},{ip_address: '42.42.42.42',public_dns: 'ec2.public.dns'})
    end

    it "should not invoke add_elastic_ip for other instance types and update the config attributes" do
      rds_instance = FactoryGirl.create(:rds_instance , resource_type: resource_type_rds)
      existing_config_attributes = JSON.parse(rds_instance.config_attributes)
      rds_instance.update_output({},{'ip_address' => '52.52.52.52','port' => '1234'})
      rds_instance.reload
      rds_instance.config_attributes.should == existing_config_attributes.merge({
          'ip_address' => '52.52.52.52',
          'port' => '1234'
        }).to_json
    end
  end

  describe "#start_ec2_instance" do

    let(:region) { FactoryGirl.create(:region) }
    let(:environment) { FactoryGirl.create(:environment, aws_name: 'TestAwsLabel', region: region) }
    let(:ec2_instance) { FactoryGirl.create(:ec2_instance, environment: environment) }

    before :each do
      environment.instances = [ec2_instance]
    end

    it "should call start_instances" do
      ec2 = Fog::Compute::AWS.new(:aws_access_key_id => 'test_id', :aws_secret_access_key => 'test_key', :region => 'us-east-1')
      Fog::Compute::AWS.should_receive(:new).with({:aws_access_key_id=>"test_id", :aws_secret_access_key=>"test_key", :region=>"us-east-1"}).and_return(ec2)
      ec2.should_receive(:start_instances)
      ec2_instance.start_ec2_instance("test_id", "test_key")
    end

  end

  describe "#stop_ec2_instance" do

    let(:region) { FactoryGirl.create(:region) }
    let(:environment) { FactoryGirl.create(:environment, aws_name: 'TestAwsLabel', region: region) }
    let(:ec2_instance) { FactoryGirl.create(:ec2_instance, environment: environment) }

    before :each do
      environment.instances = [ec2_instance]
    end

    it "should call stop_instances" do
      ec2 = Fog::Compute::AWS.new(:aws_access_key_id => 'test_id', :aws_secret_access_key => 'test_key', :region => 'us-east-1')
      Fog::Compute::AWS.should_receive(:new).with({:aws_access_key_id=>"test_id", :aws_secret_access_key=>"test_key", :region=>"us-east-1"}).and_return(ec2)
      ec2.should_receive(:stop_instances)
      ec2_instance.stop_ec2_instance("test_id", "test_key")
    end
  end

end
