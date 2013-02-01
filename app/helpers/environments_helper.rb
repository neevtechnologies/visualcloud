module EnvironmentsHelper
  def status_image(status)
   provision_status = { 
     "CREATE_COMPLETE"    => { "IMG" => "#{image_path('CREATE_COMPLETE.png')}"   , "MSG" => "Provisioned Successfully"},
     "UPDATE_COMPLETE"    => { "IMG" => "#{image_path('CREATE_COMPLETE.png')}"   , "MSG" => "Updated Successfully"},
     "CREATE_IN_PROGRESS" => { "IMG" => "#{image_path('CREATE_IN_PROGRESS.png')}", "MSG" => "Provisioning in progress"},
     "UPDATE_IN_PROGRESS" => { "IMG" => "#{image_path('CREATE_IN_PROGRESS.png')}", "MSG" => "Update in progress"},
     "CREATE_FAILED"      => { "IMG" => "#{image_path('CREATE_FAILED.png')}"     , "MSG" => "Failed to Provision"},
     "DEFAULT"            => { "IMG" => "#{image_path('default_status.png')}"    , "MSG" => "Not yet provisioned"}
    }
    status = status || 'Not yet provisioned'
    if provision_status.keys.include?(status)
      {"img_src" => provision_status[status]["IMG"],"img_title" => provision_status[status]["MSG"]}
    else
      {"img_src" => image_path("default_status.png"),"img_title" => "#{status}"}
    end
  end

  def get_select_options_for_deploy_order(id)
    environments_count = Environment.where(:project_id => id).count
    return (1..environments_count).to_a
  end

end
