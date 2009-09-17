class Employee < ActiveRecord::Base
  belongs_to :company

  searchable_by :first_name, :last_name, :occupation, :company => [:name, :abbrev]
end
