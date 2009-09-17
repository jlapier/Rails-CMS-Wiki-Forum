class Company < ActiveRecord::Base
  has_many :employees

  searchable_by :name, :abbrev, :descriptors
end
