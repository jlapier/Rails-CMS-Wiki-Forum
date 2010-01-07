class AddAboutWikiToComments < ActiveRecord::Migration
  def self.up
    add_column :wiki_comments, :about_wiki_page_id, :integer
  end

  def self.down
    remove_column :wiki_comments, :about_wiki_page_id
  end
end
