require 'spec_helper'

describe AwsCompatibleName do

  before(:all) do
    @obj = Object.new
    class << @obj
      include AwsCompatibleName
    end
  end
  
  describe "#aws_compatible_name" do

    it "should match with the AWS compatible regular expression /[a-zA-Z][-a-zA-Z0-9]+/" do
      @obj.aws_compatible_name('~!@#$%^&*(Random words)<>?/\:"\'123').should match(/[a-zA-Z][-a-zA-Z0-9]+/)
    end

    it "should append a utc timestamp at the end of the name" do 
      @time_now = Time.now.utc
      Time.stub!(:now).and_return(@time_now)
      @obj.aws_compatible_name('~!@#$%^&*(Random words)<>?/\:"\'123').should include(Time.now.to_i.to_s)
    end

  end

end
