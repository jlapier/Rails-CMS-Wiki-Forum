module FileShare
  module ApplicationHelper
    def link_wrapper(path, wrapper_options={}, link_options={})
      tag       = wrapper_options.delete(:tag) || :p
      link_text = link_options.delete(:link_text) || path

      unless wrapper_options.delete(:no_wrapper)
        return content_tag(tag, wrapper_options) do
          link_to(link_text, path, link_options)
        end
      else
        return link_to(link_text, path, link_options)
      end
    end
  
    def link_to_file_attachments(wrapper_options={}, link_options={})
      link_wrapper(file_attachments_path, wrapper_options, {
        :link_text => 'List / Upload Files'
      }.merge!(link_options))
    end
    
    def links_to_edit_and_delete_file_attachment(file_attachment, wrapper_options={}, link_options={})
      return unless has_authorization?(:update, file_attachment) || has_authorization?(:delete, file_attachment)
      content_tag :p do
        link_to_edit_file_attachment(file_attachment) + " " +
        link_to_delete_file_attachment(file_attachment)
      end
    end
    
    def link_to_edit_file_attachment(file_attachment, wrapper_options={}, link_options={})
      return unless has_authorization?(:update, file_attachment)
      link_wrapper(edit_file_attachment_path(file_attachment), {
        :no_wrapper => true
      }.merge!(wrapper_options), {
        :link_text => 'update',
        :class => 'file_attachment_dynamic_form_link fake_button'
      }.merge!(link_options))
    end
    
    def link_to_delete_file_attachment(file_attachment, wrapper_options={}, link_options={})
      return unless has_authorization?(:delete, file_attachment)
      link_wrapper(file_attachment_path(file_attachment), {
        :no_wrapper => true
      }.merge!(wrapper_options), {
        :link_text => 'delete',
        :method => :delete,
        :confirm => "Did you mean to Delete #{file_attachment.name}?",
        :class => 'fake_button'
      }.merge!(link_options))
    end
    
    def link_to_download_file_attachment(file_attachment, wrapper_options={}, link_options={})
      return unless has_authorization?(:read, file_attachment)
      link_wrapper(download_file_attachment_path(file_attachment), {
        :no_wrapper => true
      }.merge!(wrapper_options), {
        :link_text => file_attachment.name
      }.merge!(link_options))
    end
    
    def link_to_attachable(attachable, wrapper_options={}, link_options={})
      return unless has_authorization?(:read, attachable)
      link_wrapper(polymorphic_path(attachable), {
        :no_wrapper => true
      }.merge!(wrapper_options), {
        :link_text => attachable.name
      }.merge!(link_options))
    end
    
    def link_to_attachable_or_file_attachments(attachable, wrapper_options={}, link_options={})
      unless attachable.blank?
        return link_to_attachable(attachable, {
          :no_wrapper => false
        }, {
          :link_text => '< back',
          :class => 'fake_button'
        })
      else
        return link_to_file_attachments({}, {
          :link_text => '< back',
          :class => 'fake_button'
        })
      end
    end
  end
end
