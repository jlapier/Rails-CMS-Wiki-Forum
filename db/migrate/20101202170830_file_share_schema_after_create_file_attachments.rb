class FileShareSchemaAfterCreateFileAttachments < ActiveRecord::Migration
  def self.up
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
  end
end
