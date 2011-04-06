require 'digest/md5'
require 'cgi'

module GravatarHelper

  #     :default => "http://signetwork.org/images/default_avatar.gif",
  DEFAULT_OPTIONS = {
    :size => 50,
    :rating => 'PG',
    :alt => 'avatar',
    :class => 'gravatar',
  }
  
  
  
  # Return the HTML img tag for the given user's gravatar. Presumes that 
  # the given user object will respond_to "email", and return the user's
  # email address.
  def gravatar_for(user, options={})
    if user
      gravatar(user.email, options)
    else
      ''
    end
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
    "http://www.gravatar.com/avatar/#{email_hash}.jpg?".tap do |url| 
      [:rating, :size, :default].each do |opt|
        unless options[opt].nil?
          value = h(options[opt])
          url << "#{opt}=#{value}&" 
        end
      end
    end
  end
  
  
end
