class AddLayoutToContentPages < ActiveRecord::Migration
  def self.up
    add_column :content_pages, :layout, :string
  end

  def self.down
    remove_column :content_pages, :layout
  end
end
