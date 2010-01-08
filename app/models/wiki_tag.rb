# == Schema Information
# Schema version: 20100107232148
#
# Table name: wiki_tags
#
#  id   :integer       not null, primary key
#  name :string(255)   
# End Schema

class WikiTag < ActiveRecord::Base
  searchable_by :name

  validates_presence_of :name
  validates_uniqueness_of :name
  
  has_and_belongs_to_many :wiki_pages
  
  def wiki_pages_count
    @wiki_pages_count ||= wiki_pages.count
  end
  
  class << self
    def find_like(chunk)
      results = find :all, :conditions => [ "name like ?", "%#{chunk}%"],
        :limit => 10
      
      # sort by having a title with the closest match to the chunk
      results.sort_by { |wt| wt.name.gsub(chunk, '').size }
    end
  end
end
