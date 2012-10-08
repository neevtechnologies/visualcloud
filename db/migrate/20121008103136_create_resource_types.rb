class CreateResourceTypes < ActiveRecord::Migration
  def change
    create_table :resource_types do |t|
      t.string :name
      t.string :ami_id
      t.string :small_icon
      t.string :large_icon

      t.timestamps
    end
  end
end
