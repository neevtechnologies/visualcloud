require 'spec_helper'

describe Graph do
  
  context "Validations" do
    subject { FactoryGirl.create(:graph) }
    it { should validate_presence_of  :name }
  end


end
