class AddRedirectToContentPageIdToCategories < ActiveRecord::Migration
  def self.up
    add_column :categories, :redirect_to_content_page_id, :integer
  end

  def self.down
    remove_column :categories, :redirect_to_content_page_id
  end
end
