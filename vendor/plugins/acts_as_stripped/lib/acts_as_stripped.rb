module Offtheline 
  module Acts #:nodoc: all
    module Stripped
      def self.included(klass)
        klass.extend ClassMethods
      end

      module ClassMethods
        def acts_as_stripped(*attributes)
					include Offtheline::Acts::Stripped::InstanceMethods
					attributes.each do |attribute|
            define_method(attribute) { strip_tags(read_attribute(attribute).to_s) }
					end
				end
			end
			
			module InstanceMethods
				
				private
				# strip tags copied from vendor/rails/actionpack/lib/action_view/helpers/text_helper.rb
				# Strips all HTML tags from the html, including comments. This uses the html-scanner tokenizer and so its HTML parsing ability is limited by that of html-scanner.
				def strip_tags(html)     
					return html if html.blank?
					if html.index("<")
						text = ""
						tokenizer = HTML::Tokenizer.new(html)
			
						while token = tokenizer.next
							node = HTML::Node.parse(nil, 0, 0, token, false)
							# result is only the content of any Text nodes
							text << node.to_s if node.class == HTML::Text  
						end
						# strip any comments, and if they have a newline at the end (ie. line with
						# only a comment) strip that too
						text.gsub(/<!--(.*?)-->[\n]?/m, "") 
					else
						html # already plain text
					end 
				end
			end
		end
	end
end
				