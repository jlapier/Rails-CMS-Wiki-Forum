class Notifier < ActionMailer::Base
  default_url_options[:host] = SiteSetting.read_setting('hostname') || 'localhost'
  include Blog::PostsHelper

private
  def admins
    @admins ||= User.find_admins.map(&:email)
    @admins.empty? ? 'root@localhost' : @admins
  end
public
  def password_reset_instructions(user, sent_at = Time.now)
    subject    'Password Reset Instructions'
    recipients user.email
    from       SiteSetting.read_setting('site email') || 'root'
    sent_on    sent_at
    
    @edit_password_reset_url = edit_password_reset_url(user.perishable_token)
  end

  def user_created(user, sent_at = Time.now)
    subject    "New user registered: #{user.fullname}"
    recipients admins
    from       SiteSetting.read_setting('site email') || 'root'
    sent_on    sent_at

    @edit_user_url = edit_user_url(user)
    @site_title = SiteSetting.read_setting('site title')
    @user = user
  end

  def published_blog_post_updated(post, updating_user)
    subject "Published Blog Post Updated [#{post.title.truncate(23)}]"
    recipients admins
    from     SiteSetting.read_setting('site email') || 'root'
    
    @publisher_name = "#{updating_user.first_name} #{updating_user.last_name}"
    @post_title = post.title
    @post_body = truncated_post_body(post)
    @post_link = "Full Post: #{blog_post_url(post)}"
    @admin_link = "Blog Admin: #{blog_dashboard_url}"
  end
  
  def email_follower(post, follower)
    subject "[eFrog - #{post.thread.forum.title.truncate(23)}]  #{post.subject.truncate(23)}"
    recipients follower.email
    from     SiteSetting.read_setting('site email') || 'root'
    content_type "text/html"
    sent_on    Time.now
    
    @follower   =   follower.full_name
    @thread     =   post.thread
    @post_title =   ActionController::Base.helpers.sanitize(post.subject)
    @post_body  =   ActionController::Base.helpers.sanitize(post.body)
    @forum      =   @thread.forum
    @link       =   forum_message_post_url(@forum, @thread)
  end
  
end
