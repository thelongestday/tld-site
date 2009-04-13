require 'test_helper'

class InvitationTest < ActiveSupport::TestCase

  should_belong_to :invitee
  should_belong_to :inviter
  should_validate_presence_of :invitee
  should_validate_presence_of :inviter

  context "Creating an invitation" do
    context "where the invitee isn't known" do
      setup do 
        @inviter = Punter.generate(:name => 'foo bar', :email => 'foo@example.com')
        Invitation.invite_punter(@inviter, 'unknown@example.com', 'foo bar')
      end

      should "create the invitee Punter and Invitation" do
        @invitee = Punter.find_by_email('unknown@example.com')
        @inviter.reload
        @invitee.reload

        assert_equal @invitee.inviters.length, 1
        assert @invitee.inviters.include?(@inviter)
        assert_equal @inviter.invitees.length, 1
        assert @inviter.invitees.include?(@invitee)
      end
    end

  end

  context "Checking for pre-existing punters" do
    setup do
    end

    should "return nil if there isn't one" do
      Punter.expects(:find_by_email).with('unknown@example.com').returns(nil)
      assert_nil Invitation.inviters_for('unknown@example.com')
    end

    should "return an array of punters if they do exist" do
      @pr1 = Punter.generate
      @pr2 = Punter.generate
      @pe1 = Punter.generate(:email => 'unknown@example.com')
      @i1 = Invitation.generate(:inviter => @pr1, :invitee => @pe1)
      @i2 = Invitation.generate(:inviter => @pr2, :invitee => @pe1)
      assert_same_elements Invitation.inviters_for('unknown@example.com'), [ @pr1, @pr2 ]
    end
  end
end
