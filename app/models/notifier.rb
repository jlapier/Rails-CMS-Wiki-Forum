class Notifier < ActionMailer::Base
  default_url_options[:host] = SiteSetting.read_setting('hostname')

  def password_reset_instructions(user, sent_at = Time.now)
    subject    'Password Reset Instructions'
    recipients user.email
    from       SiteSetting.read_setting('site title')
    sent_on    sent_at
    
    body       :edit_password_reset_url => edit_password_reset_url(user.perishable_token)
  end

end
