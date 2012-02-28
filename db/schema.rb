# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20120220175457) do

  create_table "blog_comments", :force => true do |t|
    t.integer  "post_id"
    t.string   "status",          :default => "pending"
    t.integer  "commenter_id"
    t.string   "commenter_email"
    t.string   "commenter_name"
    t.text     "body"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "blog_comments", ["commenter_id"], :name => "index_blog_comments_on_commenter_id"
  add_index "blog_comments", ["post_id"], :name => "index_blog_comments_on_post_id"
  add_index "blog_comments", ["status"], :name => "index_blog_comments_on_status"

  create_table "blog_posts", :force => true do |t|
    t.integer  "author_id"
    t.integer  "category_id"
    t.integer  "editing_user_id"
    t.integer  "modifying_user_id"
    t.string   "title"
    t.text     "body"
    t.boolean  "published",                  :default => false
    t.datetime "started_editing_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "revisable_original_id"
    t.integer  "revisable_branched_from_id"
    t.integer  "revisable_number",           :default => 0
    t.string   "revisable_name"
    t.string   "revisable_type"
    t.datetime "revisable_current_at"
    t.datetime "revisable_revised_at"
    t.datetime "revisable_deleted_at"
    t.boolean  "revisable_is_current",       :default => true
  end

  add_index "blog_posts", ["author_id"], :name => "index_blog_posts_on_author_id"
  add_index "blog_posts", ["category_id"], :name => "index_blog_posts_on_category_id"
  add_index "blog_posts", ["editing_user_id"], :name => "index_blog_posts_on_editing_user_id"
  add_index "blog_posts", ["modifying_user_id"], :name => "index_blog_posts_on_modifying_user_id"
  add_index "blog_posts", ["title"], :name => "index_blog_posts_on_title"

  create_table "categories", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "parent_id"
    t.integer  "position"
    t.integer  "redirect_to_content_page_id"
  end

  create_table "categories_content_pages", :id => false, :force => true do |t|
    t.integer "category_id"
    t.integer "content_page_id"
  end

  add_index "categories_content_pages", ["category_id"], :name => "index_categories_content_pages_on_category_id"
  add_index "categories_content_pages", ["content_page_id"], :name => "index_categories_content_pages_on_content_page_id"

  create_table "content_pages", :force => true do |t|
    t.string   "name"
    t.text     "body"
    t.string   "special"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "is_preview_only"
    t.datetime "started_editing_at"
    t.integer  "editing_user_id"
    t.date     "publish_on"
    t.string   "layout"
    t.text     "auxiliary_body"
    t.string   "page_layout"
  end

  create_table "event_calendar_attendees", :force => true do |t|
    t.integer  "event_id"
    t.integer  "participant_id"
    t.string   "participant_type"
    t.string   "role"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "event_calendar_events", :force => true do |t|
    t.string   "name"
    t.string   "event_type"
    t.datetime "start_on"
    t.datetime "end_on"
    t.text     "location"
    t.text     "description"
    t.text     "notes"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "revisable_original_id"
    t.integer  "revisable_branched_from_id"
    t.integer  "revisable_number",           :default => 0
    t.string   "revisable_name"
    t.string   "revisable_type"
    t.datetime "revisable_current_at"
    t.datetime "revisable_revised_at"
    t.datetime "revisable_deleted_at"
    t.boolean  "revisable_is_current",       :default => true
    t.string   "timezone"
    t.text     "presenters"
    t.text     "facilitators"
    t.string   "topic"
  end

  create_table "event_calendar_events_links", :id => false, :force => true do |t|
    t.integer "event_id"
    t.integer "link_id"
  end

  add_index "event_calendar_events_links", ["event_id", "link_id"], :name => "index_event_calendar_events_links_on_event_id_and_link_id"

  create_table "event_calendar_links", :force => true do |t|
    t.string   "name"
    t.string   "url"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "file_share_file_attachments", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.string   "filepath"
    t.integer  "attachable_id"
    t.string   "attachable_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "file_share_file_attachments", ["attachable_id"], :name => "index_file_share_file_attachments_on_attachable_id"

  create_table "forums", :force => true do |t|
    t.string   "title"
    t.text     "description"
    t.integer  "position"
    t.boolean  "moderator_only"
    t.integer  "newest_message_post_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "message_posts", :force => true do |t|
    t.string   "subject"
    t.text     "body",          :limit => 16777215
    t.integer  "forum_id"
    t.integer  "parent_id"
    t.integer  "user_id"
    t.integer  "to_user_id"
    t.integer  "thread_id"
    t.datetime "replied_to_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "message_posts", ["created_at"], :name => "index_messages_on_created_at"
  add_index "message_posts", ["forum_id"], :name => "index_messages_on_forum_id"
  add_index "message_posts", ["parent_id"], :name => "index_messages_on_parent_id"
  add_index "message_posts", ["thread_id"], :name => "index_messages_on_thread_id"
  add_index "message_posts", ["to_user_id"], :name => "index_messages_on_to_user_id"
  add_index "message_posts", ["user_id"], :name => "index_messages_on_user_id"

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :null => false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "site_settings", :force => true do |t|
    t.string   "setting_name"
    t.string   "setting_string_value"
    t.text     "setting_text_value"
    t.integer  "setting_number_value"
    t.boolean  "yamled"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "user_groups", :force => true do |t|
    t.string "name"
    t.text   "special"
  end

  create_table "user_groups_users", :id => false, :force => true do |t|
    t.integer "user_id"
    t.integer "user_group_id"
  end

  add_index "user_groups_users", ["user_group_id"], :name => "index_user_groups_users_on_user_group_id"
  add_index "user_groups_users", ["user_id"], :name => "index_user_groups_users_on_user_id"

  create_table "users", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "login",                                   :null => false
    t.string   "email",                                   :null => false
    t.string   "crypted_password",                        :null => false
    t.string   "password_salt",                           :null => false
    t.string   "persistence_token",                       :null => false
    t.string   "perishable_token",                        :null => false
    t.integer  "login_count",              :default => 0, :null => false
    t.datetime "last_request_at"
    t.datetime "last_login_at"
    t.datetime "current_login_at"
    t.string   "last_login_ip"
    t.string   "current_login_ip"
    t.boolean  "is_admin"
    t.string   "first_name"
    t.string   "last_name"
    t.text     "user_defined_fields"
    t.string   "requested_user_group_ids"
    t.string   "single_access_token"
  end

  add_index "users", ["email"], :name => "index_users_on_email"
  add_index "users", ["last_request_at"], :name => "index_users_on_last_request_at"
  add_index "users", ["login"], :name => "index_users_on_login"
  add_index "users", ["perishable_token"], :name => "index_users_on_perishable_token"
  add_index "users", ["persistence_token"], :name => "index_users_on_persistence_token"

  create_table "wiki_comments", :force => true do |t|
    t.integer  "wiki_page_id"
    t.integer  "user_id"
    t.text     "body"
    t.integer  "looking_at_version"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "about_wiki_page_id"
    t.integer  "wiki_id"
  end

  add_index "wiki_comments", ["wiki_id"], :name => "index_wiki_comments_on_wiki_id"
  add_index "wiki_comments", ["wiki_page_id"], :name => "index_wiki_comments_on_wiki_page_id"

  create_table "wiki_page_versions", :force => true do |t|
    t.integer  "wiki_page_id"
    t.integer  "version"
    t.string   "title"
    t.string   "url_title"
    t.integer  "modifying_user_id"
    t.text     "body"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "started_editing_at"
    t.integer  "editing_user_id"
    t.integer  "wiki_id"
  end

  add_index "wiki_page_versions", ["wiki_id"], :name => "index_wiki_page_versions_on_wiki_id"
  add_index "wiki_page_versions", ["wiki_page_id"], :name => "index_wiki_page_versions_on_wiki_page_id"

  create_table "wiki_pages", :force => true do |t|
    t.string   "title"
    t.string   "url_title"
    t.integer  "modifying_user_id"
    t.text     "body"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "version"
    t.datetime "started_editing_at"
    t.integer  "editing_user_id"
    t.integer  "wiki_id"
  end

  add_index "wiki_pages", ["modifying_user_id"], :name => "index_wiki_pages_on_modifying_user_id"
  add_index "wiki_pages", ["url_title"], :name => "index_wiki_pages_on_url_title"
  add_index "wiki_pages", ["wiki_id"], :name => "index_wiki_pages_on_wiki_id"

  create_table "wiki_pages_wiki_tags", :id => false, :force => true do |t|
    t.integer "wiki_tag_id"
    t.integer "wiki_page_id"
  end

  add_index "wiki_pages_wiki_tags", ["wiki_page_id"], :name => "index_wiki_pages_wiki_tags_on_wiki_page_id"
  add_index "wiki_pages_wiki_tags", ["wiki_tag_id"], :name => "index_wiki_pages_wiki_tags_on_wiki_tag_id"

  create_table "wiki_tags", :force => true do |t|
    t.string  "name"
    t.integer "wiki_id"
  end

  add_index "wiki_tags", ["name"], :name => "index_wiki_tags_on_name"

  create_table "wikis", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "position"
  end

end
