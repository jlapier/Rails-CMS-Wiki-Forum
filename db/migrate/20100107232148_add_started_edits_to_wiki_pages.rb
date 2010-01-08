class AddStartedEditsToWikiPages < ActiveRecord::Migration
  def self.up
    add_column :wiki_pages, :started_editing_at, :datetime
    add_column :wiki_pages, :editing_user_id, :integer
    add_column :wiki_page_versions, :started_editing_at, :datetime
    add_column :wiki_page_versions, :editing_user_id, :integer
  end

  def self.down
    remove_column :wiki_pages, :started_editing_at
    remove_column :wiki_pages, :editing_user_id
    remove_column :wiki_page_versions, :started_editing_at
    remove_column :wiki_page_versions, :editing_user_id
  end

end
