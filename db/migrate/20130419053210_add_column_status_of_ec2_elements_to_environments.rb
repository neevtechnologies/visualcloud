class AddColumnStatusOfEc2ElementsToEnvironments < ActiveRecord::Migration
  def change
    add_column :environments, :status_of_ec2_elements , :string
    environments = Environment.all
    environments.each do |env|
      if env.provision_status == "CREATE_COMPLETE" || env.provision_status == "UPDATE_COMPLETE"
        env.status_of_ec2_elements = "running"
        env.save
      end
    end
  end
end
