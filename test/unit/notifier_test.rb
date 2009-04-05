require 'test_helper'

class NotifierTest < ActionMailer::TestCase
  test "invitation" do
    punter = Punter.new
    punter.expects(:email_with_name).returns('foo bar <foo@example.com>')
    punter.expects(:name).returns('foo bar')
    punter.expects(:authentication_token).returns('T0k3n')

    Notifier.deliver_invitation(punter, @expected.date)

    assert_sent_email do |email|
      email.to.include?('foo@example.com')
      email.from.include?('site@thelongestday.net')
      email.body.include?("You've been invited")
      email.body.include?('T0k3n')
    end
  end

end
