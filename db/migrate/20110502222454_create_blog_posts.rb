class CreateBlogPosts < ActiveRecord::Migration
  def self.up
    create_table :blog_posts do |t|
      t.integer :author_id
      t.integer :category_id
      t.integer :editing_user_id
      t.integer :modifying_user_id
      t.string :title
      t.text :body
      t.boolean :published, :default => false

      t.datetime :started_editing_at
      t.timestamps
    end
    
    add_index :blog_posts, :author_id
    add_index :blog_posts, :category_id
    add_index :blog_posts, :editing_user_id
    add_index :blog_posts, :modifying_user_id
    add_index :blog_posts, :title
#    add_index :blog_posts, :body
  end

  def self.down
    drop_table :blog_posts
  end
end
