class DeleteDataBagWorker
  include Sidekiq::Worker
  include ServerMetaData

  #Do not retry failed jobs for now. Can be changed later.
  sidekiq_options retry: false

  #Delete data bags based on deletion of Projects and Nodes(Instances).
  def perform(options={})
    options.symbolize_keys!
    delete_data_bag_item(options[:data_bag_name], options[:item_id])
  end

end
