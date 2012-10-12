FactoryGirl.define do
  factory :ami do
    name "WebServer"
    image_id "img_123"
    description "Ubuntu 12 with Ruby 1.9.3"
    architecture "64"
  end
end
