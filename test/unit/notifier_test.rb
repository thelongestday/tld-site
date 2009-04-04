require 'test_helper'

class NotifierTest < ActionMailer::TestCase
  test "invitation" do
    punter = Punter.new
    punter.expects(:email_with_name).returns('foo bar <foo@example.com>')
    punter.expects(:name).returns('foo bar')

    @expected.subject = "[TLD] You've been invited to The Longest Day"
    @expected.body    = read_fixture('invitation')
    @expected.date    = Time.now
    @expected.to      = 'foo bar <foo@example.com>'
    @expected.from    = 'site@thelongestday.net'

    assert_equal @expected.encoded, Notifier.create_invitation(punter, @expected.date).encoded
  end

end
