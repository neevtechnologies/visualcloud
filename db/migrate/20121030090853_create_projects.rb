class CreateProjects < ActiveRecord::Migration
  def change
    create_table :projects do |t|
      t.string :name
      t.string :description
      t.string :repo_type
      t.string :repo_url
      t.string :repo_auth
      t.string :frame_work
      t.boolean :managed, :default=>true
      t.references :user
      t.timestamps
    end
    create_table(:projects_users, :id => false) do |t|
      t.references :project
      t.references :user
    end

    add_index(:projects_users, [ :project_id, :user_id ])
  end
end