class CreateWikiPages < ActiveRecord::Migration
  def self.up
    create_table "wiki_pages", :force => true do |t|
      t.string   "title"
      t.string   "url_title"
      t.integer  "modifying_user_id"
      t.text     "body"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "version"
    end

    add_index "wiki_pages", ["modifying_user_id"], :name => "index_wiki_pages_on_modifying_user_id"
    add_index "wiki_pages", ["url_title"], :name => "index_wiki_pages_on_url_title"

    WikiPage.create_versioned_table
  end

  def self.down
    drop_table :wiki_pages
    WikiPage.drop_versioned_table
  end
end
