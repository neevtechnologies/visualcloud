class AddRolesToResourceType < ActiveRecord::Migration
  def change
    add_column :resource_types, :roles, :string
  end
end
