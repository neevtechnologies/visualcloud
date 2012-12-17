class CreateTableRegions < ActiveRecord::Migration

  def change
    create_table :regions do |t|
      t.string :name
      t.string :display_name
      t.float  :latitude
      t.float  :longitude
    end 
  end

end
