class CreateAmis < ActiveRecord::Migration
  def change
    create_table :amis do |t|
      t.string :image_id
      t.string :description
      t.string :architecture
      t.string :name

      t.timestamps
    end
  end
end
