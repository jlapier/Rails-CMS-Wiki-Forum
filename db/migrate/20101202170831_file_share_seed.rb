class FileShareSeed < ActiveRecord::Migration
  def self.up
    load File.join(FileShare::Engine.root, 'db', 'seeds.rb')
  end
end
