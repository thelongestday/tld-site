require 'test_helper'

class PunterTest < ActiveSupport::TestCase

  context "Punter" do
    setup do
      @punter = Punter.create!(:name => 'foo bar', :email => 'foo@example.com')
    end

    should_validate_presence_of :name, :email
    should_ensure_length_in_range :name, (6 .. 128)

    should_validate_uniqueness_of :email
    should_not_allow_values_for :email, "notreallyandemail address", :message => "doesn't look like a proper email address"
    should_ensure_length_in_range :email, (0.. 128)
    should_allow_values_for :email, "a@b.com"

    # should_validate_confirmation_of :password
    should "validate confirmation of :password" do
      @punter.password = 'hashmeup'
      @punter.valid?
      assert_contains @punter.errors.on(:password), "don't match"
      assert_contains @punter.errors.on(:password_confirmation), "don't match"
      @punter.password_confirmation = 'hashmeup'
      assert_valid @punter
    end

    should "create a email address with display name" do
      assert_equal 'foo bar <foo@example.com>', @punter.email_with_name
    end

    should "hash strings consistent with the previous site" do
      assert_equal 'bd2994f8434a199f58e571d69b82adc3dd62f767', Punter.to_hash('Never get out of the boat')
    end

    should "create random salts" do
      assert_not_equal Punter.random_salt, Punter.random_salt
    end

    should "set password correctly" do
      @punter.password = 'hashmeup'
      @punter.password_confirmation = 'hashmeup'
      Punter.expects(:random_salt).returns('ABC')
      @punter.set_password!
      assert_equal 'ABC', @punter.salt
      assert_equal 'da7beef01d68e7350d736f30f8eff4d6cd444f87', @punter.salted_password
    end

    should "set token correctly" do
      Punter.expects(:random_salt).returns('ABC')
      @punter.set_token!
      assert_equal 'e8fe100f61378807', @punter.authentication_token
    end

  end

  context "A known punter" do
    setup do
      @punter = Punter.create!(:name => 'foo bar', :email => 'foo@example.com', :password => 'foobar', :password_confirmation => 'foobar')
      @punter.set_password!
    end
    
    should "not authenticate using wrong email and password" do
      assert_raise(RuntimeError) { Punter.authenticate_by_password('bar@example.com', 'foobar') }
    end

    should "not authenticate using right email but wrong password" do
      assert_raise(RuntimeError) { Punter.authenticate_by_password('foo@example.com', 'barfoo') }
    end

    should "authenticate using right email and right password" do
      punter = Punter.authenticate_by_password('foo@example.com', 'foobar') 
      assert_equal punter, @punter
    end

    should "set last_login field when authenticating" do
      punter = Punter.authenticate_by_password('foo@example.com', 'foobar') 
      assert_in_delta Time.now, punter.last_login, 5
    end

    should "not authenticate using wrong email and token" do
      assert_raise(RuntimeError) { Punter.authenticate_by_token('bar@example.com', 'foobar') }
    end

    should "not authenticate using right email and token if one isn't set" do
      assert_raise(RuntimeError) { Punter.authenticate_by_token('foo@example.com', 'foobar') }
    end

    should "not authenticate using right email and wrong token" do
      @punter.set_token!
      assert_raise(RuntimeError) { Punter.authenticate_by_token('foo@example.com', 'foobar') }
    end

    should "authenticate using right email and right token" do
      @punter.set_token!
      punter = Punter.authenticate_by_token('foo@example.com', @punter.authentication_token) 
      assert_equal punter, @punter
    end
    
    should "clear token after authenticating with it" do
      @punter.set_token!
      punter = Punter.authenticate_by_token('foo@example.com', @punter.authentication_token) 
      assert_nil punter.authentication_token
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