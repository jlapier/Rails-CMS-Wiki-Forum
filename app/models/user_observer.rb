class UserObserver < ActiveRecord::Observer
  def after_create(user)
    Notifier.user_created(user).deliver
  end
end
