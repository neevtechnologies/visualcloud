class AddProvisionedToEnvironments < ActiveRecord::Migration
  def change
    add_column :environments, :provisioned, :boolean
  end
end
