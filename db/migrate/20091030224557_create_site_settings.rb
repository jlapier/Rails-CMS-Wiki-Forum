class CreateSiteSettings < ActiveRecord::Migration
  def self.up
    create_table :site_settings do |t|
      t.string :setting_name
      t.string :setting_string_value
      t.text :setting_text_value
      t.integer :setting_number_value
      t.boolean :yamled

      t.timestamps
    end
  end

  def self.down
    drop_table :site_settings
  end
end
