module GraphsHelper
  def get_instance_template_for_stage(resource_type)
    #controller.render_to_string(partial: "#{resource_type.name.downcase}_template", layout: false, locals: { resource_type: resource_type })
    render "#{resource_type.name.downcase}_template", resource_type: resource_type
  rescue Exception => e
    #Rails.logger.error('Error occured while creating resource draggable: #{e.inspect}')
    return ''
  end
end
