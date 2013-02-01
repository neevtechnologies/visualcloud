require 'spec_helper'

describe ResourceType do

  context "Associations" do
    it { should have_many(:instance_types) }
    it { should have_many(:instances) }
  end  

end