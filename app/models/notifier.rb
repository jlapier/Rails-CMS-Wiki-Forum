class Notifier < ActionMailer::Base
  default_url_options[:host] = SiteSetting.read_setting('hostname') || 'localhost'

  def password_reset_instructions(user, sent_at = Time.now)
    subject    'Password Reset Instructions'
    recipients user.email
    from       SiteSetting.read_setting('site title')
    sent_on    sent_at
    
    @edit_password_reset_url = edit_password_reset_url(user.perishable_token)
  end

  def user_created(user, sent_at = Time.now)
    admins = User.find_admins.map(&:email)
    admins = 'root@localhost' if admins.empty?
    subject    "New user registered: #{user.fullname}"
    recipients admins
    from       SiteSetting.read_setting('site title')
    sent_on    sent_at

    @edit_user_url = edit_user_url(user)
    @site_title = SiteSetting.read_setting('site title')
    @user = user
  end

end
