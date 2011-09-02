module ContentPagesHelper
  def page_name
    @content_page ? @content_page.name : ''
  end

  def page_body
    @content_page ? @content_page.body_for_display : ''
  end

  def auxiliary_content
    @content_page ? @content_page.aux_body_for_display : ''
  end

  def category_links
    if @content_page and not @content_page.categories.empty?
      out = '<p class="category_links"> Categories: '
      out += @content_page.categories.map { |cat| link_to(cat.name, cat) }.join(', ')
      out += '</p>'
      out.html_safe
    end
  end
end
