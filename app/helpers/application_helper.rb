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
      #{message}
    </div>)

    html.html_safe
  end

  def get_key_pairs_select(key_pairs)
    return key_pairs.collect{|key_pair| key_pair["keyName"]}
  end

  def get_security_groups_select(security_groups)
    return security_groups.collect{|security_group| security_group["groupName"]}
  end

end
