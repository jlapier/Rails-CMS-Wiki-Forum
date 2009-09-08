class CreateForums < ActiveRecord::Migration
  def self.up
    create_table :forums do |t|
      t.string :title
      t.text :description
      t.integer :position
      t.boolean :moderator_only
      t.integer :newest_message_post_id

      t.timestamps
    end
  end

  def self.down
    drop_table :forums
  end
end
