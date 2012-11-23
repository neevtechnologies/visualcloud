class AddStatusToEnvironments < ActiveRecord::Migration
  def change
    add_column :environments, :provision_status, :string
  end
end
