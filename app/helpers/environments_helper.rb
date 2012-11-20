module EnvironmentsHelper
  def status_image(status)
    status.present? ? image_tag("#{status}.gif", title: "#{status}", rel: 'tooltip') : image_tag("default_status.gif", title: "Not yet Provisioned!", rel: 'tooltip')
  end
end
