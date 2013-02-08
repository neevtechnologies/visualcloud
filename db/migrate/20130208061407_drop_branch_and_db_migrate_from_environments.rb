class DropBranchAndDbMigrateFromEnvironments < ActiveRecord::Migration
  def up
    remove_column :environments , :branch
    remove_column :environments , :db_migrate
    remove_column :environments , :deploy_order
  end

  def down
    add_column :environments , :branch , :string, :default => "master"
    add_column :environments , :db_migrate , :boolean , :default => true
    add_column :environments , :deploy_order , :integer
  end
end
