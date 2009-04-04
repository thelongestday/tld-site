class Punter < ActiveRecord::Base
  validates_presence_of :name, :email
  validates_uniqueness_of :email

  include AASM

  aasm_column :state
  aasm_initial_state :new
  aasm_state :new
  aasm_state :invited, :enter => :send_invitation
  aasm_state :confirmed
  aasm_state :rejected

  aasm_event :invite do
    transitions :from => :new, :to => :invited
  end

  aasm_event :confirm do
    transitions :from => :invited, :to => :confirmed
  end

  aasm_event :reject do
    transitions :from => [ :new, :invited, :confirmed ], :to => :rejected
  end

  def email_with_name 
    "#{self.name} <#{self.email}>"
  end

  protected

  def send_invitation
    Notifier.deliver_invitation(self)
  end

end

