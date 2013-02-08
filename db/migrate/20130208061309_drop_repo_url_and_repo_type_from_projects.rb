class DropRepoUrlAndRepoTypeFromProjects < ActiveRecord::Migration
  def up
    remove_column :projects , :repo_type
    remove_column :projects , :repo_url
  end

  def down
    add_column :projects , :repo_type , :string
    add_column :projects , :repo_url , :string
  end
end
