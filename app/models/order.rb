class Order < ActiveRecord::Base
  belongs_to :owner, :class_name => 'Punter'
  validates_presence_of :owner
  attr_protected :owner

  has_many :tickets

  include AASM

  aasm_column :state
  aasm_initial_state :provisional
  aasm_state :provisional
  aasm_state :ordered
  aasm_state :paid
  aasm_state :cancelled

  aasm_event :mark_ordered do
    transitions :from => :provisional, :to => :ordered
  end

  aasm_event :mark_paid do
    transitions :from => :ordered, :to => :paid
  end

  aasm_event :cancel do
    transitions :from => :provisional, :to => :cancelled
    transitions :from => :ordered,     :to => :cancelled
  end

end
