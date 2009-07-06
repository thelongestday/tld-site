require 'test_helper'

class OrderTest < ActiveSupport::TestCase
  should_have_many :tickets
  should_have_many :paypal_logs
  should_belong_to :owner
  should_not_allow_mass_assignment_of :owner
  should_not_allow_mass_assignment_of :state
  should_ensure_value_in_range  :children, ( 0 .. 5 ), :high_message => /less than/, :low_message => /greater than/

  context "tickets" do
    setup do 
      @o = Order.generate!
    end 

    should "add a well formed ticket" do
      @p = Punter.generate!
      @o.add_ticket_by_punter_id(@p.id)
      
      assert_equal @o.tickets.first.punter, @p
      assert_equal @o.tickets.first.cost, Site::Config.event.cost
    end

    should "handle invalid punter id" do
      @o.add_ticket_by_punter_id(732)
    end

    should "work out the total of its tickets" do
      @p1 = Punter.generate!
      @p2 = Punter.generate!

      @o.add_ticket_by_punter_id(@p1.id)
      @o.add_ticket_by_punter_id(@p2.id)

      @o.tickets.first.update_attribute(:cost, 732)
      @o.tickets.last.update_attribute(:cost,  65536)

      assert_equal 732 + 65536, @o.total_cost
    end
  end

  context "paypal" do
    should "possess a uid" do
      o = Order.create
      o.id = 732
      o.owner_id = 1024
      o.created_at = Time.at(1)

      assert_equal o.uid, "a2fda26d"
    end
  end

end
