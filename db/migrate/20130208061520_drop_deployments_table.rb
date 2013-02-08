class DropDeploymentsTable < ActiveRecord::Migration
  def up
    drop_table :deployments
  end

  def down
    create_table :deployments do |t|
      t.string :revision
      t.string :status
      t.references :environment
      t.timestamps
    end
  end
end
