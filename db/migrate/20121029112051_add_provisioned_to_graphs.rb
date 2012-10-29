class AddProvisionedToGraphs < ActiveRecord::Migration
  def change
    add_column :graphs, :provisioned, :boolean
  end
end
