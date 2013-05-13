class AddColumnInstanceStatusToInstances < ActiveRecord::Migration
  def change
    add_column :instances, :instance_status, :string
  end
end
