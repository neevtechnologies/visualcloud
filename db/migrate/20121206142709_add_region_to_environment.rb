class AddRegionToEnvironment < ActiveRecord::Migration
  def change
    add_column :environments, :region_id, :integer
  end
end
