# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  
  def print_flash
    return '' if flash.empty?
    
    output = ''
    flash.each do |key, message|
      output << "<div class=\"#{key}\">"
      if message.is_a?(Hash) && message[:base]
        output << "<b>#{message[:base]}</b>"
        message[:messages].each do |error|
          output << "<br/>#{error}" unless error == message[:base]
        end
      else
        output << "<b>#{message}</b>"
      end
      output << "</div>"
    end
    output
  end

  # Will paginate method override.
  def paginate(collection = nil)
    will_paginate collection, :previous_label => t('common.paginate_previous'), :next_label => t('common.paginate_next')
  end  
end
