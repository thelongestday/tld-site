require 'test_helper'

class OrderTest < ActiveSupport::TestCase
  should_have_many :tickets
  should_belong_to :owner
  should_not_allow_mass_assignment_of :owner
  should_not_allow_mass_assignment_of :state

  context "tickets" do
    setup do 
      @o = Order.generate!
    end

    should "add a well formed ticket" do
      @p = Punter.generate!
      @o.add_ticket_by_punter_id(@p.id)
      
      assert_equal @o.tickets.first.punter, @p
      assert_equal @o.tickets.first.cost, Site::Config::event.cost
    end
  end

end
