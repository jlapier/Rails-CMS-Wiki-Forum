class AddPositionToWikis < ActiveRecord::Migration
  def self.up
    add_column :wikis, :position, :integer
  end

  def self.down
    remove_column :wikis, :position
  end
end
