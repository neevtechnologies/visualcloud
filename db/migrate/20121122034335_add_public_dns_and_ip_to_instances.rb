class AddPublicDnsAndIpToInstances < ActiveRecord::Migration
  def change
    add_column :instances, :public_dns, :string
    add_column :instances, :private_ip, :string
  end
end
