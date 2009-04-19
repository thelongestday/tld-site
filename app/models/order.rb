class Order < ActiveRecord::Base
  belongs_to :owner, :class_name => 'Punter'
  validates_presence_of :owner
  attr_protected :owner, :state

  has_many :tickets

  include AASM

  aasm_column :state
  aasm_initial_state :new
  aasm_state :new
  aasm_state :ordered
  aasm_state :paid
  aasm_state :cancelled

  aasm_event :mark_ordered do
    transitions :from => :new, :to => :ordered
  end

  aasm_event :mark_paid do
    transitions :from => :ordered, :to => :paid
  end

  aasm_event :cancel do
    transitions :from => :new,     :to => :cancelled
    transitions :from => :ordered, :to => :cancelled
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

end
