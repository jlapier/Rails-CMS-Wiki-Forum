# == Schema Information
# Schema version: 20091027220707
#
# Table name: categories
#
#  id         :integer       not null, primary key
#  name       :string(255)   
#  created_at :datetime      
#  updated_at :datetime      
# End Schema

class Category < ActiveRecord::Base
  has_and_belongs_to_many :content_pages
  validates_presence_of :name
end
