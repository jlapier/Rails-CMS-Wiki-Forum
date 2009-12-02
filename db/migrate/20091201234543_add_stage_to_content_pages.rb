class AddStageToContentPages < ActiveRecord::Migration
  def self.up
    add_column :content_pages, :is_preview_only, :boolean
  end

  def self.down
    remove_column :content_pages, :is_preview_only
  end
end
