class CreateComponents < ActiveRecord::Migration
  def change
    create_table :components do |t|
      t.string :name
      t.string :small_icon
      t.string :large_icon

      t.timestamps
    end
  end
end
