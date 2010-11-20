class Ability
  include CanCan::Ability

  def initialize(user)
    @user = user
    
    if user.is_admin?
      setup_admin
    else
      setup_user
    end
  end
  
  def setup_admin
    can :manage, :all
  end
  
  def setup_user
    can :read, Forum do |forum|
      @user.has_read_access_to?(forum)
    end
    can :write, Forum do |forum|
      @user.has_write_access_to?(forum)
    end
    can :read, Wiki do |wiki|
      @user.has_read_access_to?(wiki)
    end
    can :write, Wiki do |wiki|
      @user.has_write_access_to?(wiki)
    end
  end
end
