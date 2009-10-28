class CreateCategories < ActiveRecord::Migration
  def self.up
    create_table :categories do |t|
      t.string :name

      t.timestamps
    end
    
    create_table "categories_content_pages", :id => false, :force => true do |t|
      t.integer "category_id"
      t.integer "content_page_id"
    end

    add_index "categories_content_pages", ["content_page_id"]
    add_index "categories_content_pages", ["category_id"]
  end

  def self.down
    drop_table :categories
  end
end
