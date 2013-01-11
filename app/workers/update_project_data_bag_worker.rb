class UpdateProjectDataBagWorker
  include Sidekiq::Worker
  include ServerMetaData
  
  #Do not retry failed jobs for now. Can be changed later.
  sidekiq_options retry: false

  #Update projects data bag for the given object.
  def perform(obj)
    project = Project.find(obj['id'])
    update_project_data_bag(project)
  end
  
end
