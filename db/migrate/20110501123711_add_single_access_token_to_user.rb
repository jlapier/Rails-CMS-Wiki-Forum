class AddSingleAccessTokenToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :single_access_token, :string
    User.all.each do |user| # trigger generation of single_access_tokens
      user.save!
    end
  end

  def self.down
    remove_column :users, :single_access_token
  end
end
