module MessagePostsHelper
  # TODO: change this to use the zoned plugin or something
	def post_time(time)
		if (Time.now - time) > 2600000
			time.strftime "on %b %d, %Y"
		else
			time_ago_in_words(time) + " ago"
		end
	end

end
