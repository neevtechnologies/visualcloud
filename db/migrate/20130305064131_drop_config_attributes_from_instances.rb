class DropConfigAttributesFromInstances < ActiveRecord::Migration
  def up
    instances = Instance.all
    instances.each do |instance|
      config_attributes = instance.attributes['config_attributes']
      instance.config_attributes = config_attributes
      instance.save
    end
    remove_column :instances , :config_attributes
  end

  def down
    add_column :instances, :config_attributes, :text
  end
end
