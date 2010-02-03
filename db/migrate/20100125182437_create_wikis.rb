class CreateWikis < ActiveRecord::Migration
  def self.up
    create_table :wikis do |t|
      t.string :name
      t.text :description
      
      t.timestamps
    end
  end

  def self.down
    drop_table :wikis
  end
end
