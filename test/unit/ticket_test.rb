require 'test_helper'

class TicketTest < ActiveSupport::TestCase
  should_belong_to :order
  should_belong_to :punter

  should_validate_presence_of :order
  should_validate_presence_of :punter

  should_not_allow_mass_assignment_of :cost

  should "delegates :paid? to Order" do
    t = Ticket.generate!
    t.order.expects(:paid?).returns(true)
    assert t.paid?
  end

end
