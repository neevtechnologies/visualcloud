module EnvironmentsHelper
  def status_image(status)
    image_tag("#{status}.gif", title: "#{status}", rel: 'tooltip') if status.present?
  end
end
