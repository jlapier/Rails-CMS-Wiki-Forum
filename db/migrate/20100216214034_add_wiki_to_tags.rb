class AddWikiToTags < ActiveRecord::Migration
  def self.up
    add_column :wiki_tags, :wiki_id, :integer
  end

  def self.down
    remove_column :wiki_tags, :wiki_id
  end
end
