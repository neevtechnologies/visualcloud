#Load VisualCloudConfigs
VisualCloudConfig = YAML.load_file("#{Rails.root}/config/config.yml")[Rails.env].symbolize_keys
