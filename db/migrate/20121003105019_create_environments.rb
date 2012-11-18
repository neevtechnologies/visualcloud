class CreateEnvironments < ActiveRecord::Migration
  def change
    create_table :environments do |t|
      t.string :name
      t.string :branch, :default => "master"
      t.boolean :db_migrate, :default => true
      t.integer :deploy_order
      t.references :project
      t.timestamps
    end
  end
end
