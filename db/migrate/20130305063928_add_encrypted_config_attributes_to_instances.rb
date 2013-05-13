class AddEncryptedConfigAttributesToInstances < ActiveRecord::Migration
  def change
    add_column :instances, :encrypted_config_attributes, :text
  end
end
