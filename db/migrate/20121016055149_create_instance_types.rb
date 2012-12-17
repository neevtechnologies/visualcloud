class CreateInstanceTypes < ActiveRecord::Migration
  def change
    create_table :instance_types do |t|
      t.string :name      
      t.string :size
      t.references :resource_type
      t.string :label
      t.string :description
      t.timestamps
    end
  end
end
