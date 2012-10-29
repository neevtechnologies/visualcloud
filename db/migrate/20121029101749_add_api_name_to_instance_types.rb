class AddApiNameToInstanceTypes < ActiveRecord::Migration
  def change
    add_column :instance_types, :api_name, :string
  end
end
