module JsonFormatter

  def projects_json project
    "{
      \"id\": \"#{project.id}\",
      \"name\":\"#{project.name}\",
      \"repo\": \"#{project.repo_url}\",
      \"deploy_key\": \"#{project.repo_auth}\",
      \"environments\": 
       #{project.environments.each do |environment| 
          "{ 
            \"id\": \"#{environment.id}\",
            \"environment\": \"#{environment.name}\",
            \"branch\": \"#{environment.branch}\",
            \"migrate\": \"#{environment.db_migrate}\" 
           }"
         end}
    }"
  end
  
  def nodes_json node
    "{
      \"id\": \"#{node.id}\",
      \"environment_id\":\"#{node.environment_id}\",
      \"project_id\":\"#{node.environment.project_id}\"
    }"
  end
    
end
