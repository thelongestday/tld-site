class Ticket < ActiveRecord::Base
  belongs_to :order
  belongs_to :punter
  belongs_to :event

  validates_presence_of :order, :punter, :event
  attr_protected :cost, :event, :punter

  def paid?
    self.order.paid?
  end

  # if the Ticket exists, but isn't paid it's still on order
  def on_order?
    !self.paid?
  end

  # ActiveScaffold
  def to_label
    self.punter.name_with_email
  end

end
