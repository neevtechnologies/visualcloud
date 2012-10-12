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
end
