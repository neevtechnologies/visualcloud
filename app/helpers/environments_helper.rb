module EnvironmentsHelper
  def status_image(status)
    if (["CREATE_COMPLETE","UPDATE_COMPLETE","CREATE_IN_PROGRESS","UPDATE_IN_PROGRESS"].include?status)
      {"img_src" => image_path("#{status}.gif"),"img_title" => "#{status}"}
    else
      {"img_src" => image_path("default_status.gif"),"img_title" => "#{status}"}
    end
  end
end
