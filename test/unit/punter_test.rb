require 'test_helper'

class PunterTest < ActiveSupport::TestCase

  context "Punter" do
    setup do
      @punter = Punter.create!(:name => 'foo bar', :email => 'foo@example.com')
    end

    should_validate_presence_of :name, :email
    should_validate_uniqueness_of :email

    should "create a email address with display name" do
      assert_equal 'foo bar <foo@example.com>', @punter.email_with_name
    end
  end


  context "A new punter" do
    setup do
      @punter = Punter.create!(:name => 'foo bar', :email => 'foo@example.com')
    end

    should "be in state 'new'" do
      assert_equal 'new', @punter.state
    end

    should "move to state 'invited' upon invite!" do
      @punter.invite!
      assert_equal 'invited', @punter.state
    end

    should "move to state 'rejected' upon reject!" do
      @punter.reject!
      assert_equal 'rejected', @punter.state
    end

    should "call send_invitation upon invite!" do
      # @punter.expects(:send_invitation)
      Notifier.expects(:deliver_invitation).with(@punter)
      @punter.invite!
    end

    should "not become confirmed" do
      assert_raise(AASM::InvalidTransition) { @punter.confirm! }
    end

  end

  context "An invited punter" do
    setup do
      @punter = Punter.create!(:name => 'foo bar', :email => 'foo@example.com')
      @punter.invite!
    end

    should "move to state 'confirmed' upon confirm!" do
      @punter.confirm!
      assert_equal 'confirmed', @punter.state
    end

    should "move to state 'rejected' upon reject!" do
      @punter.reject!
      assert_equal 'rejected', @punter.state
    end

    should "not become re-invited" do
      assert_raise(AASM::InvalidTransition) { @punter.invite! }
    end
  end

  context "A confirmed punter" do
    setup do
      @punter = Punter.create!(:name => 'foo bar', :email => 'foo@example.com')
      @punter.invite!
      @punter.confirm!
    end

    should "move to state 'rejected' upon reject!" do
      @punter.reject!
      assert_equal 'rejected', @punter.state
    end

    should "not become re-invited" do
      assert_raise(AASM::InvalidTransition) { @punter.invite! }
    end
  end

end
