FactoryGirl.define do
  factory :rds_instance , class: :instance do
    label "MySQL"
    config_attributes ({key1: 'value1', key2: 'value2'}.to_json)
    xpos 100
    ypos 200
  end
end

FactoryGirl.define do
  factory :ec2_instance, class: :instance  do
    label "WebServer"
    config_attributes ({key1: 'value1', key2: 'value2', roles: ['app', 'java']}.to_json)
    xpos 300
    ypos 400
  end
end

FactoryGirl.define do
  factory :elb_instance, class: :instance  do
    label "LoabBalancer"
    config_attributes ({key1: 'value1', key2: 'value2'}.to_json)
    xpos 300
    ypos 400
  end
end

FactoryGirl.define do
  factory :s3_instance, class: :instance  do
    label "S3Bucket"
    config_attributes ({key1: 'value1', key2: 'value2'}.to_json)
    xpos 300
    ypos 400
  end
end

FactoryGirl.define do
  factory :elasticache_instance, class: :instance  do
    label "ElastiCache"
    config_attributes ({key1: 'value1', key2: 'value2'}.to_json)
    xpos 300
    ypos 400
  end
end