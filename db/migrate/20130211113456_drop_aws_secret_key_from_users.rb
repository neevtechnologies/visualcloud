class DropAwsSecretKeyFromUsers < ActiveRecord::Migration
  def up
    users = User.all
    users.each do |user|
      aws_secret_key = user.attributes['aws_secret_key']
      user.aws_secret_key = aws_secret_key
      user.save
    end
    remove_column :users , :aws_secret_key
  end

  def down
    add_column :users, :aws_secret_key, :string
  end
end
