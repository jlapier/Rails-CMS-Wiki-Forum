class AddAuxBodyToContentPages < ActiveRecord::Migration
  def self.up
    add_column :content_pages, :auxiliary_body, :text
  end

  def self.down
    remove_column :content_pages, :auxiliary_body
  end
end
