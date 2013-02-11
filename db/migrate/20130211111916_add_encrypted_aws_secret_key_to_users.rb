class AddEncryptedAwsSecretKeyToUsers < ActiveRecord::Migration
  def change
    add_column :users, :encrypted_aws_secret_key, :string
  end
end
