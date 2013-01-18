require 'spec_helper'

describe JsonFormatter do
  describe "nodes_json" do
    include JsonFormatter
    it "should return the proper json" do
      project = FactoryGirl.create(:project)
      env = FactoryGirl.create(:environment, project: project)
      ec2_instance = FactoryGirl.create(:ec2_instance, environment: env)
      JSON.parse(nodes_json(ec2_instance)).should == {
        "id" => ec2_instance.id.to_s,
        "environment_id" => env.id.to_s,
        "project_id" => project.id.to_s,
        "config_attributes" => JSON.parse(ec2_instance.config_attributes)
      }
    end
  end
end
