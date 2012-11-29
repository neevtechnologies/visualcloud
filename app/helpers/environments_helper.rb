module EnvironmentsHelper
  def status_image(status)
   provision_status = { 
     "CREATE_COMPLETE"    => { "IMG" => "#{image_path('CREATE_COMPLETE.png')}"   , "MSG" => "Provisioned Successfully"},
     "UPDATE_COMPLETE"    => { "IMG" => "#{image_path('CREATE_COMPLETE.png')}"   , "MSG" => "Provisioned Successfully"},
     "CREATE_IN_PROGRESS" => { "IMG" => "#{image_path('CREATE_IN_PROGRESS.png')}", "MSG" => "Provisioning .."},
     "UPDATE_IN_PROGRESS" => { "IMG" => "#{image_path('CREATE_IN_PROGRESS.png')}", "MSG" => "Provisioning .."},
     "CREATE_FAILED"      => { "IMG" => "#{image_path('CREATE_FAILED.png')}"     , "MSG" => "Failed to Provision"}
    }
    status = status || 'Not yet provisioned.'
    if provision_status.keys.include?(status)
      {"img_src" => provision_status[status]["IMG"],"img_title" => provision_status[status]["MSG"]}
    else
      {"img_src" => image_path("default_status.png"),"img_title" => "#{status}"}
    end
  end
end
