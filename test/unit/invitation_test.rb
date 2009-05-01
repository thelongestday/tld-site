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
        assert @invitee.inviters.include?(@inviter)
        assert @inviter.invitees.include?(@invitee)
      end
    end

    context "where the invitee is already known" do
      setup do 
        @pr1 = Punter.generate(:name => 'foo bar', :email => 'foo@example.com')
        @pr2 = Punter.generate(:name => 'foo bar', :email => 'woo@example.com')
        @pe1 = Punter.generate(:name => 'foo bar', :email => 'bar@example.com')
        @i1  = Invitation.generate(:inviter => @pr1, :invitee => @pe1)
        Invitation.invite_punter(@pr2, 'bar@example.com', 'foo bar')
      end

      should "create the new Invitation" do
        assert @pe1.inviters.include?(@pr1)
        assert @pe1.inviters.include?(@pr2)
        assert @pr1.invitees.include?(@pe1)
        assert @pr1.invitees.include?(@pe1)
      end
    end

    context "where the invitee is already invited by the inviter" do
      setup do 
        @pr1 = Punter.generate(:name => 'foo bar', :email => 'foo@example.com')
        @pe1 = Punter.generate(:name => 'foo bar', :email => 'bar@example.com')
        @i1  = Invitation.generate(:inviter => @pr1, :invitee => @pe1)
      end

      should "not be valid" do
        assert_raise(PunterException) { Invitation.invite_punter(@pr1, 'bar@example.com', 'foo bar') }
      end
    end

    context "where the invitee is an inviter of the inviter" do
      setup do 
        @p1 = Punter.generate(:name => 'foo bar', :email => 'foo@example.com')
        @p2 = Punter.generate(:name => 'foo bar', :email => 'bar@example.com')
        @i1 = Invitation.generate(:inviter => @p1, :invitee => @p2)
      end

      should "not be valid" do
        assert_raise(PunterException) { Invitation.invite_punter(@p2, @p1.email, @p1.name) }
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
