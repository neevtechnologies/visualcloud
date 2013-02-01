require 'spec_helper'

describe Project do

  context "Validations" do
    subject { FactoryGirl.create(:project) }
    it { should validate_uniqueness_of(:name).scoped_to(:user_id) }
  end

  context "Associations" do
    it { should have_and_belong_to_many(:users) }
    it { should have_many(:environments) }
    it { should accept_nested_attributes_for(:environments) }

    let(:project) {FactoryGirl.create(:project)}
    let(:environment) {FactoryGirl.create(:environment,project: project)}
    let(:environment) {FactoryGirl.create(:environment,project: project)}
    it "should destroy associated environments" do
      environments = project.environments
      project.destroy
      environments.should be_empty
    end
  end


end
