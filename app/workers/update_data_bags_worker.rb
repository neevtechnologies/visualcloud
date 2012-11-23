class UpdateDataBagsWorker
  include Sidekiq::Worker
  include ServerMetaData
  
  #Do not retry failed jobs for now. Can be changed later.
  sidekiq_options retry: false

  #Update data bags based on creation, updation and deletion of Projects and Nodes(Instances).
  def perform(options)
    options.symbolize_keys!
    data_bag_name = options[:data_bag_name]
    item_id = options[:item_id]
    delete_data_bag_item(data_bag_name, item_id)
  end
  
end
