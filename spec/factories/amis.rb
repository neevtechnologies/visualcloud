FactoryGirl.define do
  factory :ami do
    name "WebServer"
    image_id ({'us-east-1' => 'useastimage', 'us-west-1' => 'uswestimage'}).to_yaml
    description "Ubuntu 12 with Ruby 1.9.3"
    architecture "64"
  end
end
