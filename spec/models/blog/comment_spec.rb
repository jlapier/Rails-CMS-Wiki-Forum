require 'spec_helper'

describe Blog::Comment do
  pending "add some examples to (or delete) #{__FILE__}"
end

# == Schema Information
#
# Table name: blog_comments
#
#  id              :integer         not null, primary key
#  post_id         :integer
#  status          :string(255)
#  commenter_id    :integer
#  commenter_email :string(255)
#  commenter_name  :string(255)
#  body            :text
#  created_at      :datetime
#  updated_at      :datetime
#

