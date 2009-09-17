class CreateMessagePosts < ActiveRecord::Migration
  def self.up
    create_table :message_posts do |t|
      t.string :subject
      t.text :body, :limit => 16777215
      t.integer :forum_id
      t.integer :parent_id
      t.integer :user_id
      t.integer :to_user_id
      t.integer :thread_id
      t.datetime :replied_to_at

      t.timestamps
    end
    
    add_index :message_posts, ["created_at"], :name => "index_messages_on_created_at"
    add_index :message_posts, ["forum_id"], :name => "index_messages_on_forum_id"
    add_index :message_posts, ["parent_id"], :name => "index_messages_on_parent_id"
    add_index :message_posts, ["thread_id"], :name => "index_messages_on_thread_id"
    add_index :message_posts, ["to_user_id"], :name => "index_messages_on_to_user_id"
    add_index :message_posts, ["user_id"], :name => "index_messages_on_user_id"
  end

  def self.down
    drop_table :message_posts
  end
end
