module StringCleaner

	# get rid of weird characters from pasting from Word and stuff
	def cleanup(text)
		if text
			text.
				gsub(/&amp;/, '&').
				gsub(/&[lr]?quot;/, '"').
				gsub(/&apos;/, "'").
				gsub(/&#39;/, "'").
				gsub(/&gt;/, '>').
				gsub(/&lt;/, '<').
				gsub(/&nbsp;/, ' ').
				gsub(%r{</?[^>]+>}, '').
				gsub(/\*\s*\*/, '**').
				gsub(/\342\200\235/, '"').
				gsub(/\342\200\234/, '"').
				gsub(/\342\200\231/, "'").
				gsub(/\342\200\223/, " -- ").
				gsub(/\342\200\224/, " -- ").
				gsub(/\303\242/, "a").
				gsub(/\303\251/, "e").
				gsub(%r{/+\s*$}, '')
		else
			nil
		end
	end


	class ActiveRecord::Base
		def cleanup_text
			self.attributes.select { |att,val| val.is_a?(String) }.map { |a,v| a.to_sym }.each { |att| self[att] = cleanup(self[att]) }
		end
	end

end
