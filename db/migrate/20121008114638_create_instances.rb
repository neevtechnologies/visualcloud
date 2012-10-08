class CreateInstances < ActiveRecord::Migration
  def change
    create_table :instances do |t|
      t.string :label
      t.string :aws_instance_id
      t.integer :size
      t.string :url
      t.integer :xpos
      t.integer :ypos

      t.timestamps
    end
  end
end
