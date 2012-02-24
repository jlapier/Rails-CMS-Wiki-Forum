module FileAttachmentsHelper

  def description_display(file_attachment)
    return unless has_authorization?(:read, file_attachment)
    content_tag :p, {
      :id => "file_attachment_#{file_attachment.id}_description",
      :class => 'file_attachment_description'
    } do
      file_attachment.description
    end
  end
  
  def name_display(file_attachment)
    content_tag :p, {
      :id => "file_attachment_#{file_attachment.id}_name",
      :class => 'file_attachment_name'
    } do
      link_to_download_file_attachment(file_attachment)
    end
  end
  
  def file_container_data(file_attachment)
    return unless has_authorization?(:update, file_attachment)
    content_tag :span, file_attachment.file_container, {
      :id => "file_attachment_#{file_attachment.id}_file_container",
      :class => "file_attachment_file_container",
      :style => "display:none;"
    }
  end
end
