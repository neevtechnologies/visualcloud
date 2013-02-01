# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :user do
    name 'Test User'
    email 'example@example.com'
    password 'please'
    password_confirmation 'please'
    aws_access_key 'test_id'
    aws_secret_key 'test_key'
    # required if the Devise Confirmable module is used
    # confirmed_at Time.now
  end
end