require 'spec_helper'

describe InstanceType do

  context "Associations" do
    it { should belong_to(:resource_type) }
    it { should have_many(:instances) }
  end

  describe ".get_select_collection" do
    it "should return an array of array containing description and ids" do
      InstanceType.delete_all
      resource_type = FactoryGirl.create(:resource_type)
      instance_type = FactoryGirl.create(:instance_type, resource_type: resource_type)
      return_value = InstanceType.get_select_collection(resource_type.name)
      return_value.should == [[instance_type.description, instance_type.id]]
    end
  end

end
