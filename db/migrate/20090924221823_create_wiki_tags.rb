class CreateWikiTags < ActiveRecord::Migration
  def self.up
    create_table "wiki_tags", :force => true do |t|
      t.string "name"
    end

    add_index "wiki_tags", ["name"], :name => "index_wiki_tags_on_name"

    create_table "wiki_taggings", :force => true do |t|
      t.integer "wiki_tag_id"
      t.integer "wiki_page_id"
    end

    add_index "wiki_taggings", ["wiki_page_id"], :name => "index_wiki_taggings_on_wiki_page_id"
    add_index "wiki_taggings", ["wiki_tag_id"], :name => "index_wiki_taggings_on_wiki_tag_id"
  end

  def self.down
    drop_table :wiki_tags
    drop_table :wiki_taggings
  end
end
