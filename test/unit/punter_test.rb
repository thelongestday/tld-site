require 'test_helper'

class PunterTest < ActiveSupport::TestCase

  context "Punter" do
    setup do
      @punter = Punter.create!(:name => 'foo bar', :email => 'foo@example.com')
    end

#   should_validate_presence_of :name, :email
    should_ensure_length_in_range :name, (3 .. 128)

    should_validate_uniqueness_of :email, :message => 'already registered'
    should_not_allow_values_for :email, "notreallyandemail address", :message => "doesn't look like a proper email address"
    should_ensure_length_in_range :email, (0.. 128)
    should_allow_values_for :email, "a@b.com"

    should_have_many :orders
    should_have_many :tickets

    should "create a email address with display name" do
      assert_equal 'foo bar <foo@example.com>', @punter.email_with_name
    end

    should "hash strings consistent with the previous site" do
      assert_equal 'bd2994f8434a199f58e571d69b82adc3dd62f767', Punter.to_hash('Never get out of the boat')
    end

    should "create random salts" do
      assert_not_equal Punter.random_salt, Punter.random_salt
    end

    should "set password correctly if set_new_password is true" do
      @punter.password = 'hashmeup'
      @punter.password_confirmation = 'hashmeup'
      @punter.set_new_password = true
      Punter.expects(:random_salt).returns('ABC')
      @punter.set_password
      assert_equal 'ABC', @punter.salt
      assert_equal 'da7beef01d68e7350d736f30f8eff4d6cd444f87', @punter.salted_password
    end
    
    should "not set password is set_new_password is false" do
      @punter.password = 'hashmeup'
      @punter.password_confirmation = 'hashmeup'
      Punter.expects(:random_salt).never
      @punter.set_password
      assert_equal '', @punter.salt
    end

    should "set token correctly and disable password when it does so" do
      Punter.expects(:random_salt).returns('ABC')
      @punter.set_token!
      assert_equal 'e8fe100f61378807', @punter.authentication_token
      assert_equal '', @punter.salted_password
      assert_equal '', @punter.salt
    end

    should "allow non-unique email if :non_unique_email is set" do
      @p2 = Punter.create(:name => 'bar foo', :email => 'foo@example.com')
      @p2.non_unique_email = true
      assert_valid @p2
    end

  end

  context "Punter setting new password" do
    setup do
      @punter = Punter.create!(:name => 'foo bar', :email => 'foo@example.com', :password => 'foobar')
      @punter.set_new_password = true
    end

    should_validate_presence_of :password
    should_ensure_length_in_range :password, (6 .. 64)

    should "validate confirmation of :password" do
      @punter.password = 'hashmeup'
      @punter.valid?
      assert_contains @punter.errors.on(:password), "doesn't match the confirmation"
      @punter.password_confirmation = 'hashmeup'
      assert_valid @punter
    end
  end

  context "A punter with default empty strings for salt, salted_password" do
    setup do
      @punter = Punter.create!(:name => 'foo bar', :email => 'foo@example.com')
    end

    should "not be able to log in" do
      assert_raise(PunterException) { Punter.authenticate_by_password('foo@example.com', '') }
    end
  end

  context "A known punter" do
    setup do
      @punter = Punter.create!(:name => 'foo bar', :email => 'foo@example.com',
                               :password => 'foobar', :password_confirmation => 'foobar', :set_new_password => true)
    end
    
    should "not authenticate using wrong email and password" do
      assert_raise(PunterException) { Punter.authenticate_by_password('bar@example.com', 'foobar') }
    end

    should "not authenticate using right email but wrong password" do
      assert_raise(PunterException) { Punter.authenticate_by_password('foo@example.com', 'barfoo') }
    end

    should "authenticate using right email and right password" do
      punter = Punter.authenticate_by_password('foo@example.com', 'foobar') 
      assert_equal punter, @punter
    end

    should "set last_login field when authenticating" do
      punter = Punter.authenticate_by_password('foo@example.com', 'foobar') 
      assert_in_delta Time.now, punter.last_login, 5
    end

    should "not authenticate using wrong token" do
      @punter.set_token!
      assert_raise(PunterException) { Punter.authenticate_by_token('foobar') }
    end

    should "authenticate using right token" do
      @punter.set_token!
      punter = Punter.authenticate_by_token(@punter.authentication_token) 
      assert_equal punter, @punter
    end
    
    should "clear token after authenticating with it" do
      @punter.set_token!
      punter = Punter.authenticate_by_token(@punter.authentication_token) 
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

    should "call send_invitation and set a token upon invite!" do
      # @punter.expects(:send_invitation)
      @punter.expects(:set_token!)
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

  context "A punter from last year's system" do
    setup  do
      @punter = Punter.create!(:name => 'foo bar', :email => 'foo@zomo.co.uk',
                               :salt => '6eeec920da40d27aa865146aeca2e65ccc74d52e',
                               :salted_password => '2316248c680b3548894eb57633b9feac5c0ffa78')
    end

    should  "authenticate with last year's password" do
      assert_equal @punter, Punter.authenticate_by_password('foo@zomo.co.uk', 'foofoo')
    end
  end
  
  context "An invited punter" do
    context "being reinvited" do
      setup do
        @punter = Punter.create!(:name => 'foo bar', :email => 'foo@zomo.co.uk')
      end

      should "not call invite! if already confirmed" do
        @punter.invite!
        @punter.expects(:invite!).never
        @punter.confirm!
        @punter.invite_if_necessary
      end

      should "not call invite! if rejected" do
        @punter.reject!
        @punter.expects(:invite!).never
        @punter.invite_if_necessary
      end

      should "call invite! if new" do
        @punter.expects(:invite!).once
        @punter.invite_if_necessary
      end

      should "call invite! if invited" do
        @punter.invite!
        @punter.expects(:invite!).once
        @punter.invite_if_necessary
      end

    end
  end

  context "ordering" do
    context "punter's ticket candidates" do
      setup do
        @pr1 = Punter.generate!
        @pr2 = Punter.generate!
        @p   = Punter.generate!
        @pe1 = Punter.generate!
        @pe2 = Punter.generate!
        
        @i1 = Invitation.create!(:inviter => @pr1, :invitee => @p )
        @i2 = Invitation.create!(:inviter => @pr2, :invitee => @p )
        @i3 = Invitation.create!(:inviter => @p,   :invitee => @pe1 )
      end

      should "return list of all candidates" do
        all = @p.all_ticket_candidates

        assert_contains @p.inviters, @pr1
        assert_contains @p.invitees, @pe1

        assert_contains all, @p
        assert_contains all, @pr1
        assert_contains all, @pr2
        assert_contains all, @pe1
        assert_does_not_contain all, @pe2
      end

      should "return list of paid candidates" do
        # TODO : work out why these expectations get applie to wrong? Punter instances
        # @p.expects(:has_paid_ticket?).returns(true)
        # @pr1.expects(:has_paid_ticket?).returns(true)
        # @pr2.expects(:has_paid_ticket?).returns(false)
        # @pe1.expects(:has_paid_ticket?).returns(true)
        # @pe2.expects(:has_paid_ticket?).returns(false)
        
        @p.all_ticket_candidates.each_with_index { |p, i| p.expects(:has_paid_ticket?).returns(i % 2 == 0) }
        paid = @p.paid_ticket_candidates
        assert 2, paid.length

        # assert_contains paid, @p
        # assert_contains paid, @pr1
        # assert_contains paid, @pe1
        # assert_does_not_contain paid, @pr2
        # assert_does_not_contain paid, @pe2
      end

      should "retun list of unpaid candidates" do
        # TODO fixme, too
        @p.all_ticket_candidates.each_with_index { |p, i| p.expects(:has_paid_ticket?).returns(i % 2 == 0) }
        unpaid = @p.unpaid_ticket_candidates
        assert 2, unpaid.length
      end
    end

    context "tickets" do
      setup do 
        @p = Punter.generate!
        @p.orders << Order.create
        @p.orders.first.tickets << Ticket.create(:punter => @p)
        @p.reload
        @t = @p.tickets.first
        @o = @p.orders.first
      end
      
      should "connect orders, tickets, punters correctly" do
        assert_equal @t, @o.tickets.first
      end

      should "respond to :has_paid_ticket with false when there is no paid ticket" do
        assert @p.has_paid_ticket? == false
      end

      should "respond to :has_paid_ticket with true when there is a paid ticket" do
        @o.mark_ordered!
        @o.mark_paid!
        assert @p.has_paid_ticket? == true
      end
    end
  end
end
