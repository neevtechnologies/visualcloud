class DeleteNodeWorker
  include Sidekiq::Worker
  include ManageNodes

  #Do not retry failed jobs for now. Can be changed later.
  sidekiq_options retry: false

  #Delete nodes and clients.
  def perform(obj_id, options={})
    delete_client(obj_id)
    delete_node(obj_id)
  end

end
