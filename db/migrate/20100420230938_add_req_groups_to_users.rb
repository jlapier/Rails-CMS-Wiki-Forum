class AddReqGroupsToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :requested_user_group_ids, :string
  end

  def self.down
    remove_column :users, :requested_user_group_ids
  end
end
