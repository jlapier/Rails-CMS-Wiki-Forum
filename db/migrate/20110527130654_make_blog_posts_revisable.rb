class MakeBlogPostsRevisable < ActiveRecord::Migration
  def self.up
    add_column :blog_posts, :revisable_original_id, :integer  
    add_column :blog_posts, :revisable_branched_from_id, :integer  
    add_column :blog_posts, :revisable_number, :integer, :default => 0  
    add_column :blog_posts, :revisable_name, :string  
    add_column :blog_posts, :revisable_type, :string  
    add_column :blog_posts, :revisable_current_at, :datetime  
    add_column :blog_posts, :revisable_revised_at, :datetime  
    add_column :blog_posts, :revisable_deleted_at, :datetime  
    add_column :blog_posts, :revisable_is_current, :boolean, :default => 1  
  end

  def self.down
    remove_column :blog_posts, :revisable_original_id  
    remove_column :blog_posts, :revisable_branched_from_id  
    remove_column :blog_posts, :revisable_number  
    remove_column :blog_posts, :revisable_name  
    remove_column :blog_posts, :revisable_type  
    remove_column :blog_posts, :revisable_current_at  
    remove_column :blog_posts, :revisable_revised_at  
    remove_column :blog_posts, :revisable_deleted_at  
    remove_column :blog_posts, :revisable_is_current  
  end
end
