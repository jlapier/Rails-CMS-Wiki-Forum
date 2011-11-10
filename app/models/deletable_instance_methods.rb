module DeletableInstanceMethods
  def restore
    self.revisable_deleted_at = nil
    self.revisable_is_current = true
    save
  end
end

