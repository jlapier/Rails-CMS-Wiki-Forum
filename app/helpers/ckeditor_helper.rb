module CkeditorHelper
  def initialize_ckeditor(textarea_id, upload_path)
    upload_path += "?authenticity_token=#{form_authenticity_token}"
    javascript_tag do
      %Q{CKEDITOR.replace('#{textarea_id}', {
        filebrowserUploadUrl: '#{upload_path}'
      });}
    end
  end
  
  def ckeditor_text_area(form)
    if form.object.new_record?
      content_tag :p do
        content_tag :em do
          "Note: after creating this new #{form.object.to_english}"+
          ", you will be able to add content."
        end
      end
    else
      out = content_tag :div, :style => 'border: 1px solid #666; background: #FFD;'+
                                  ' padding: 4px 8px; margin-bottom: 12px;',
                        :class => 'small_text' do
        "To easily link to another #{form.object.to_english}, just use the format:<br />".html_safe +
        "[[Title of Another Page]]"
      end
      out += form.text_area :body, :rows => 10, :cols => 80, :style => 'width: 90%;'
      out
    end
  end
  
  def ckeditor_confirm_exit(exit_confirmed_post_path)
    javascript_tag do
      %Q{
        var needToConfirm = true;

        window.onbeforeunload = confirmExit;
        function confirmExit() {
          if (needToConfirm) {
            return 'You may have unsaved changes.';
          }
        }

        window.onunload = function() {
          if (needToConfirm) {
            $.post('#{exit_confirmed_post_path}');
          }
        }        
      }
    end
  end
  
  def ckeditor_confirm_exit_submit(form)
    form.submit "Save", :onclick => "needToConfirm = false;"
  end
  
  def wip_warning(obj)
    return '' if obj.editing_user.blank? or obj.editing_user == current_user
    
    inner_content = content_tag :em do
      content_tag(:strong, 'Warning:') + " Another person is currently editing"+
                                         " this #{obj.to_english}!"
    end
    inner_content += content_tag :br
    inner_content += "#{obj.editing_user.fullname} started editing "+
                     time_ago_in_words(obj.started_editing_at)
    
    content_tag :div, :class => "flash_message error_message" do
      inner_content
    end
  end
end
