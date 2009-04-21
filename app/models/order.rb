class Order < ActiveRecord::Base
  belongs_to :owner, :class_name => 'Punter'
  has_many :tickets
  has_many :paypal_logs, :foreign_key => 'item_number'

  validates_presence_of :owner
  attr_protected :owner, :state

  include AASM

  aasm_column :state
  aasm_initial_state :new
  aasm_state :new
  aasm_state :confirmed
  aasm_state :paid, :enter => :send_receipt
  aasm_state :cancelled

  aasm_event :confirm do
    transitions :from => :new, :to => :confirmed
  end

  aasm_event :pay do
    transitions :from => :confirmed, :to => :paid
  end

  aasm_event :cancel do
    transitions :from => :new,     :to => :cancelled
    transitions :from => :confirmed, :to => :cancelled
  end

  def add_ticket_by_punter_id(punter_id)
    begin
      punter = Punter.find(punter_id)
      ticket = Ticket.create
      ticket.update_attribute(:cost,   Site::Config.event.cost)
      ticket.update_attribute(:event,  Site::Config.event)
      ticket.update_attribute(:order,  self)
      ticket.update_attribute(:punter, punter)
      self.tickets << ticket
    rescue ActiveRecord::RecordNotFound
      logger.error("Tried to add #{p.to_i} to new Order, but Punter doesn't exist")
    end
  end

  def total_cost
    # XXX - why does this not work?
    # self.tickets.inject { |total, ticket| total + ticket.cost }
    total = 0
    self.tickets.each { |t| total += t.cost }
    total
  end

  def uid
    return Digest::SHA1.hexdigest("#{self.id}-#{self.owner_id}-#{self.created_at}")[0..7]
  end    

  # protected - XXX
  
  def send_receipt
    return unless self.paid?
    Notifier.deliver_ticket_sale_receipt(self)
    tickets.each do |t|
      Notifier.deliver_ticket_sale_message(self, t)
    end
  end
end
