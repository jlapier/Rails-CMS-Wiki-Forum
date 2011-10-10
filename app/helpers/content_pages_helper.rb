module ContentPagesHelper
  def page_name
    @content_page ? @content_page.name : ''
  end

  def main_category(include_parents = true)
    return unless @content_page and !@content_page.categories.empty?
    main_cat = @content_page.categories.first
    get_parent_categories(main_cat)
  end

  def get_parent_categories(cat)
    out = (cat.parent ? get_parent_categories(cat.parent) : '') +
      link_to(cat.name, cat) + ': '
    out.html_safe
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
