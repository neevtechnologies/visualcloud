module EnvironmentsHelper
  def status_image(status)
    if (["CREATE_COMPLETE","CREATE_IN_PROGRESS"].include?status)
      {"img_src" => image_path("#{status}.png"),"img_title" => "#{status}"}
    else
      {"img_src" => image_path("default_status.png"),"img_title" => "Not yet provisioned!"}
    end
  end
end
