class AddKeyPairAndSecurityGroupToEnvironments < ActiveRecord::Migration
  def change
   add_column :environments, :key_pair_name, :string
   add_column :environments, :security_group, :string
  end
end
