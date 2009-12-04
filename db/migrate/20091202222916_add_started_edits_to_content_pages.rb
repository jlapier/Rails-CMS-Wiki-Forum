class AddStartedEditsToContentPages < ActiveRecord::Migration
  def self.up
    add_column :content_pages, :started_editing_at, :datetime
    add_column :content_pages, :editing_user_id, :integer
    add_column :content_pages, :publish_on, :date
  end

  def self.down
    remove_column :content_pages, :started_editing_at
    remove_column :content_pages, :editing_user_id
    remove_column :content_pages, :publish_on
  end
end
