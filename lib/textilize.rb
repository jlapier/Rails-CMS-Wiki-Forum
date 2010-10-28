module Textilize
  def textilize(text)  
    RedCloth.new(text).to_html.html_safe unless text.blank?  
  end
  
  def textilize_without_paragraph(text)
    textiled = textilize(text)
    if textiled[0..2] == "<p>" then textiled = textiled[3..-1] end
    if textiled[-4..-1] == "</p>" then textiled = textiled[0..-5] end
    return textiled
  end  
end
