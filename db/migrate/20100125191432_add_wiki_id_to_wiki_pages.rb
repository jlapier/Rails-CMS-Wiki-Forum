class AddWikiIdToWikiPages < ActiveRecord::Migration
  def self.up
    add_column :wiki_pages, :wiki_id, :integer
    add_index :wiki_pages, :wiki_id
    add_column :wiki_page_versions, :wiki_id, :integer
    add_index :wiki_page_versions, :wiki_id
    
    add_column :wiki_comments, :wiki_id, :integer
    add_index :wiki_comments, :wiki_id
  end

  def self.down
    remove_column :wiki_pages, :wiki_id
    remove_column :wiki_page_versions, :wiki_id
    remove_column :wiki_comments, :wiki_id
  end
end
