module JsonFormatter

  #Creates a JSON for projects databag
  # *options-
  #   {<ENVIRONMENT_ID>: {:master_db_address => "<IP_ADDRESS_OF_MASTER_DB>"}}
  def projects_json(project, options={})
    environments_json = []
    project.environments.each do |environment| 
      options_json = ""
      options_for_environment = options[environment.id] || {}
      options_for_environment.each do |key, value|
         options_json += "  \"#{key.to_s}\": \"#{value.to_s}\",\n"
      end
      environments_json << " 
        \"#{environment.id}\": {
        #{options_json}
        \"environment\": \"#{environment.name}\",
        \"branch\": \"#{environment.branch}\",
        \"migrate\": \"#{environment.db_migrate}\" 
       }"
    end

    "{
      \"id\": \"#{project.id}\",
      \"name\":\"#{project.name}\",
      \"repo\": \"#{project.repo_url}\",
      \"environments\": {#{environments_json.join(',')}}
    }"
  end
  
  def nodes_json(node)
    "{
      \"id\": \"#{node.id}\",
      \"environment_id\":\"#{node.environment_id}\",
      \"project_id\":\"#{node.environment.project_id}\",
      \"config_attributes\":#{node.config_attributes}
    }"
  end
    
end
