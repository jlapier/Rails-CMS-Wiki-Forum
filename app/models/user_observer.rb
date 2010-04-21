class UserObserver < ActiveRecord::Observer
  def after_create(user)
    Notifier.deliver_user_created(user)
  end
end
