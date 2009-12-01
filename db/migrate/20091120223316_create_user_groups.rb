class CreateUserGroups < ActiveRecord::Migration
  def self.up
    create_table :user_groups do |t|
      t.string :name
      t.string :special
    end

    create_table :user_groups_users, :id => false do |t|
      t.column :user_id, :integer
			t.column :user_group_id, :integer
    end

		add_index :user_groups_users, :user_id
		add_index :user_groups_users, :user_group_id
  end

  def self.down
    drop_table :user_groups
    drop_table :user_groups_users
  end
end
