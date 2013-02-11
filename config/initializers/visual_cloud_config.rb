#Load VisualCloudConfigs
VisualCloudConfig = YAML.load_file("#{Rails.root}/config/config.yml")[Rails.env].symbolize_keys

error = "\nAttribute encryption key not set in config/config.yml. Set attr_encryption_salt to a random string\n".red
raise error if VisualCloudConfig[:attr_encryption_salt].blank?
