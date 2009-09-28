class CreateWikiComments < ActiveRecord::Migration
  def self.up
    create_table "wiki_comments", :force => true do |t|
      t.integer  "wiki_page_id"
      t.integer  "user_id"
      t.text     "body"
      t.integer  "looking_at_version"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "wiki_comments", ["wiki_page_id"], :name => "index_wiki_comments_on_wiki_page_id"

  end

  def self.down
    drop_table :wiki_comments
  end
end
