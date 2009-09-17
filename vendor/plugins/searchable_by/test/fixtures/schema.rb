ActiveRecord::Schema.define do

  create_table "employees", :force => true do |t|
    t.column "first_name", :string
    t.column "last_name",  :string
    t.column "occupation", :string
    t.column "company_id", :integer
    t.column "created_at", :datetime
    t.column "updated_at", :datetime
  end

  create_table "companies", :force => true do |t|
    t.column "name", :string
    t.column "abbrev", :string
    t.column "descriptors", :text
  end

end
