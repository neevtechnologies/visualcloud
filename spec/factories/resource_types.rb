FactoryGirl.define do
  factory :resource_type , class: :resource_type do
      name "RDS"
      resource_class "RDS"
    end
  end

FactoryGirl.define do
  factory :instance_type , class: :instance_type do
      name 'Micro'
      api_name 'cache.t1.micro'
    end
  end

FactoryGirl.define do
  factory :region , class: :region do
      name 'us-east-1'      
    end
  end