# == Schema Information
# Schema version: 20100216214034
#
# Table name: wikis
#
#  id          :integer       not null, primary key
#  name        :string(255)   
#  description :text          
#  created_at  :datetime      
#  updated_at  :datetime      
# End Schema

class Wiki < ActiveRecord::Base
  alias_attribute :title, :name
  has_many :wiki_pages
  has_many :wiki_comments
  has_many :wiki_tags

  class << self
    def all_wikis
      find :all, :order => 'name'
    end
  end
end
