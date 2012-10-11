module ApplicationHelper

  #--------------------------------------------------------------------------
  # Used to display flash messages
  #--------------------------------------------------------------------------
  def flash_messages
    formatted_messages = flash.collect do |type, message|
      content_tag(:div, inline_message(type, message), class: "messages")
    end
    formatted_messages.join.html_safe
  end

  def inline_message(type, messages)
    message = ""
    if messages.is_a?(Array)
      messages.each do |msg|
        message += "<p>#{msg}</p>"
      end
    else
      message = messages
    end

    html = %(<div class="alert alert-#{type}">
      <button type="button" class="close" data-dismiss="alert">x</button>
      #{message}
    </div>)

    html.html_safe
  end

end
