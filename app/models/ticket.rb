class Ticket < ActiveRecord::Base
  belongs_to :order
  belongs_to :punter

  validates_presence_of :order, :punter

  def paid?
    self.order.paid?
  end

end
