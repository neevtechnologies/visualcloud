class CreateDeployments < ActiveRecord::Migration
  def change
    create_table :deployments do |t|
      t.string :revision
      t.string :status
      t.references :environment
      t.timestamps
    end
  end
end
