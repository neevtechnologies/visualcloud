class AddStatusToEnvironments < ActiveRecord::Migration
  def change
    add_column :environments, :status, :string
  end
end
