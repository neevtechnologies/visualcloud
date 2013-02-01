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

end
