class AddAwsCompatibleFields < ActiveRecord::Migration

  def change 
    add_column :projects, :aws_name, :string
    add_column :environments, :aws_name, :string
    add_column :instances, :aws_label, :string
  end

end
