# == Schema Information
# Schema version: 20091120223316
#
# Table name: user_groups
#
#  id   :integer       not null, primary key
#  name :string(255)   
# End Schema

class UserGroup < ActiveRecord::Base
  has_and_belongs_to_many :users

  class << self
    def find_by_name(name)
      @groups ||= {}
      @groups[name] ||= find( :first, :conditions => { :name => name })
    end

    def find_or_create_by_name(name)
      find_by_name(name) || create(:name => name)
    end
  end
end
