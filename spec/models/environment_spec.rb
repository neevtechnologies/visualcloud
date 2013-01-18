require 'spec_helper'

describe Environment do

  context "Validations" do
    subject { FactoryGirl.create(:environment) }
    it { should validate_presence_of  :name }
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
