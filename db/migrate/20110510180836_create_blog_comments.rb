class CreateBlogComments < ActiveRecord::Migration
  def self.up
    create_table :blog_comments do |t|
      t.integer :post_id
      t.string :status, :default => 'pending'
      t.integer :commenter_id
      t.string :commenter_email
      t.string :commenter_name
      t.text :body

      t.timestamps
    end
    
    add_index :blog_comments, :commenter_id
    add_index :blog_comments, :post_id
    add_index :blog_comments, :status
  end

  def self.down
    drop_table :blog_comments
  end
end
