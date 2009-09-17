require 'digest/md5'
require 'cgi'

module GravatarHelper

  DEFAULT_OPTIONS = {
    :default => "http://aethora.com/images/hunting.gif",
    :size => 50,
    :rating => 'PG',
    :alt => 'avatar',
    :class => 'gravatar',
  }
  
  
  
  # Return the HTML img tag for the given user's gravatar. Presumes that 
  # the given user object will respond_to "email", and return the user's
  # email address.
  def gravatar_for(user, options={})
    gravatar(user.email, options)
  end

  # Return the HTML img tag for the given email address's gravatar.
  def gravatar(email, options={})
    src = h(gravatar_url(email, options))
    options = DEFAULT_OPTIONS.merge(options)
    [:class, :alt, :size].each { |opt| options[opt] = h(options[opt]) }
    "<img class=\"#{options[:class]}\" alt=\"#{options[:alt]}\" width=\"#{options[:size]}\" "+
      "height=\"#{options[:size]}\" src=\"#{src}\" />"      
  end

  # Return the gravatar URL for the given email address.
  def gravatar_url(email, options={})
    email_hash = Digest::MD5.hexdigest(email)
    options = DEFAULT_OPTIONS.merge(options)
    options[:default] = CGI::escape(options[:default]) unless options[:default].nil?
    returning "http://www.gravatar.com/avatar/#{email_hash}.jpg?" do |url| 
      [:rating, :size, :default].each do |opt|
        unless options[opt].nil?
          value = h(options[opt])
          url << "#{opt}=#{value}&" 
        end
      end
    end
  end
  
  
end