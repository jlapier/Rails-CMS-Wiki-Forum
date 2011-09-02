class AddPageLayoutToContentPages < ActiveRecord::Migration
  def self.up
    add_column :content_pages, :page_layout, :string
  end

  def self.down
    remove_column :content_pages, :page_layout
  end
end
