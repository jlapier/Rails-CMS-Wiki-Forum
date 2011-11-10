class Ability
  include CanCan::Ability

  def initialize(user)    
    if user.is_admin?
      setup_admin
    else
      setup_user(user)
    end
    
    alias_action :list_by_tag, :to => :read
    alias_action :search, :to => :read
  end
  
  def setup_admin
    can :manage, :all
  end
  
  def setup_user(user)
    setup_forum_access(user)
    setup_wiki_access(user)
    setup_blog_access(user)
    can :read, EventCalendar::Event
    can :read, FileAttachment
    can :download, FileAttachment
  end
  
  # WikisController before_filters (original)
  #   :require_admin_user, :except => [:index, :show, :tag_index, :tagcloud, :list_by_tag]
  #   :require_wiki_read_access, :only => [:show, :tag_index, :tagcloud, :list_by_tag]
  def setup_wiki_access(user)
    can :read, Wiki do |wiki| # todo create sql to use for Wiki.accessible_by
      user.has_read_access_to?(wiki)
    end
    # can? :create, WikiPage.new, @wiki
    can :create, WikiPage do |wiki_page, wiki|
      user.has_read_access_to?(wiki)
    end
    # all wiki pages are available for allowed groups
    can :read, WikiPage do |wiki_page|
      user.has_read_access_to?(wiki_page.wiki)
    end
    can :update, WikiPage do |wiki_page|
      user.has_read_access_to?(wiki_page.wiki)
    end
    can :delete, WikiPage do |wiki_page|
      user.has_write_access_to?(wiki_page.wiki)
    end
  end
  
  # ForumsController before_filters (original)
  #   :require_admin_user, :except => [:index, :show]
  #   :require_forum_read_access, :only => [:show]
  #   :require_forum_write_access, :only => [:edit, :update, :destroy]
  def setup_forum_access(user)
    # Forum & MessagePost
    can :read, Forum do |forum|
      user.has_read_access_to?(forum)
    end
    # all posts available to all users in allowed groups
    can :read, MessagePost do |message_post|
      user.has_read_access_to?(message_post.forum)
    end
    # write access to forum req'd for posting
    #can :create, MessagePost do |message_post|
    #  user.has_write_access_to?(message_post.forum)
    #end
    # only the author can update forum posts - they must retain forum write privs
    can :update, MessagePost do |message_post|
      user.has_write_access_to?(message_post.forum) &&
      user.id == message_post.user_id
    end
  end
  
  def setup_blog_access(user)
    can :read, Blog::Post do |post|
      post.published or user == post.author
    end
    can :create, Blog::Post
    can :update, Blog::Post do |post|
      user == post.author
    end
    can :delete, Blog::Post do |post|
      user == post.author and !post.published
    end
  end
end
