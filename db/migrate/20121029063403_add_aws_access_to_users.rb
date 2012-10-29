class AddAwsAccessToUsers < ActiveRecord::Migration
  def change
    add_column :users, :aws_secret_key, :string
    add_column :users, :aws_access_key, :string
  end
end
