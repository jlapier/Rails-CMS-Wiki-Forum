# == Schema Information
# Schema version: 20091202222916
#
# Table name: user_groups
#
#  id      :integer       not null, primary key
#  name    :string(255)   
#  special :string(255)   
# End Schema

class UserGroup < ActiveRecord::Base
  SPECIAL_ACCESS = [ 'Wiki Reader', 'Wiki Editor', 'Forum Poster', 'Forum Moderator' ]

  # stored as an Array - list of indexes of SPECIAL_ACCESS
  serialize :special, Array

  has_and_belongs_to_many :users

  before_save :integerize_special_index

  class << self
    def find_by_name(name)
      @groups ||= {}
      @groups[name] ||= find( :first, :conditions => { :name => name })
    end

    def find_or_create_by_name(name)
      find_by_name(name) || create(:name => name)
    end
  end

  def access_string
    special.map { |i| SPECIAL_ACCESS[i] }.join(', ')
  end

  def drop_users(drop_user_ids)
    drop_user_ids = [*drop_user_ids].compact.map(&:to_i)
    self.user_ids = user_ids - drop_user_ids
    self.save
  end

  private

  def integerize_special_index
    self.special = special.map { |n| n.to_i }
  end
end
