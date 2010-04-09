require 'test_helper'

class NotifierTest < ActionMailer::TestCase
  test "password_reset_instructions" do
    @expected.subject = 'Notifier#password_reset_instructions'
    @expected.body    = read_fixture('password_reset_instructions')
    @expected.date    = Time.now

    assert_equal @expected.encoded, Notifier.create_password_reset_instructions(@expected.date).encoded
  end

end
