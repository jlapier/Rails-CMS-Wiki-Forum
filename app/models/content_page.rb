# == Schema Information
# Schema version: 20091027220707
#
# Table name: content_pages
#
#  id          :integer       not null, primary key
#  name        :string(255)   
#  body        :text          
#  category_id :integer       
#  created_at  :datetime      
#  updated_at  :datetime      
# End Schema

class ContentPage < ActiveRecord::Base
  validates_presence_of :name
  has_and_belongs_to_many :categories

  class << self
    def find_or_create_by_name(name)
      cp = find_by_name(name)
      cp || ContentPage.create( :name => name, :body => "<p>TO DO: edit this page</p>" )
    end
  end
end
