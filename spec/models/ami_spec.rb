require 'spec_helper'

describe Ami do
  describe ".get_select_collection" do
    it "should return an array of array containing description and ids" do
      Ami.delete_all
      ami = FactoryGirl.create(:ami)
      return_value = Ami.get_select_collection
      return_value.should == [[ami.description, ami.id]]
    end
  end

  describe "#image" do
    it "should return image_id for the requested region" do
      ami = FactoryGirl.create(:ami)
      ami.image('us-east-1').should == 'useastimage'
      ami.image('us-west-1').should == 'uswestimage'
    end
  end

end
