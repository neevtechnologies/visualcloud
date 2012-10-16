FactoryGirl.define do
  factory :rds_instance , class: :instance do
    label "MySQL"
    xpos 100
    ypos 200
  end
end

FactoryGirl.define do
  factory :ec2_instance, class: :instance  do
    label "WebServer"
    xpos 300
    ypos 400
  end
end
