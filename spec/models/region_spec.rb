require 'spec_helper'

describe Region do

  context "Associations" do
    it { should have_many(:environments) }
  end

  describe ".region_list" do
    it "should return an array of hashes to json" do
      results = []
      Region.delete_all
      region1 = FactoryGirl.create(:region , latitude: '100', longitude: '100', name: "region-1", display_name: "region-1display_name")
      region2 = FactoryGirl.create(:region , latitude: '200', longitude: '200', name: "region-2", display_name: "region-2display_name")
      results << {latLng: [region1.latitude,region1.longitude], name: region1.name, display_name: region1.display_name, id: region1.id}
      results << {latLng: [region2.latitude,region2.longitude], name: region2.name, display_name: region2.display_name, id: region2.id}
      Region.region_list.should == results.to_json
    end
  end

end
