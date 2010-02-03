class ChangeSpecialInUserGroups < ActiveRecord::Migration
  def self.up
    change_column :user_groups, :special, :text
  end

  def self.down
    change_column :user_groups, :special, :string
  end
end
