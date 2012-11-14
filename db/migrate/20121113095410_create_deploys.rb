class CreateDeploys < ActiveRecord::Migration
  def change
    create_table :deploys do |t|
      t.string :revision
      t.string :status
      t.references :environment
      t.timestamps
    end
  end
end
