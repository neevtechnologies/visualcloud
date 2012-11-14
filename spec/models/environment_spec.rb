require 'spec_helper'

describe Environment do
  
  context "Validations" do
    subject { FactoryGirl.create(:environment) }
    it { should validate_presence_of  :name }
  end


end
