class UserObserver < ActiveRecord::Observer
  def after_create(user)
    if User.count > 1
      Notifier.user_created(user).deliver
    end
  end
end
