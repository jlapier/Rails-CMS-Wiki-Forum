# == Schema Information
# Schema version: 20100125191432
#
# Table name: wikis
#
#  id         :integer       not null, primary key
#  name       :string(255)   
#  created_at :datetime      
#  updated_at :datetime      
# End Schema

class Wiki < ActiveRecord::Base
  alias_attribute :title, :name
  has_many :wiki_pages
  has_many :wiki_comments

  class << self
    def all_wikis
      find :all, :order => 'name'
    end
  end
end
