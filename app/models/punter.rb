require 'regex'

class Punter < ActiveRecord::Base
  validates_presence_of :name, :email
  validates_uniqueness_of :email, :if => :validate_unique_email?, :message => 'already registered'
  validates_length_of :name, :within => 3 .. 128
  validates_length_of :email, :maximum => 128

  validates_presence_of :password, :if => :validate_password?
  validates_length_of :password, :within => 6 .. 64, :if => :validate_password?

  before_save :set_password
  before_save :downcase_email
  after_save :clear_tmp_password

  has_many :sent_invitations, :foreign_key => 'inviter_id', :class_name => 'Invitation'
  has_many :received_invitations, :foreign_key => 'invitee_id', :class_name => 'Invitation'
  has_many :invitees, :through => :sent_invitations, :source => :invitee
  has_many :inviters, :through => :received_invitations, :source => :inviter

  has_many :orders, :foreign_key => 'owner_id'
  has_many :tickets

  attr_accessor :password, :password_confirmation, :set_new_password, :non_unique_email
  attr_protected :state, :admin

  include AASM

  aasm_column :state
  aasm_initial_state :new
  aasm_state :new
  aasm_state :invited, :enter => :send_invitation
  aasm_state :confirmed
  aasm_state :rejected

  aasm_event :invite do
    transitions :from => :new,     :to => :invited
    transitions :from => :invited, :to => :invited
  end

  aasm_event :confirm do
    transitions :from => :new,       :to => :confirmed
    transitions :from => :invited,   :to => :confirmed
    transitions :from => :confirmed, :to => :confirmed
  end

  aasm_event :reject do
    transitions :from => [ :new, :invited, :confirmed ], :to => :rejected
  end

  def all_ticket_candidates
    all = self.inviters + self.invitees
    all << self
    all.reject { |p| p.id == Site::Config.root_user.id || !p.confirmed? }
  end

  def downcase_email
    self.email.downcase!
  end

  def clear_tmp_password
    self.password = nil
    self.password_confirmation = nil
    self.set_new_password = nil
  end

  def email_with_name 
    "#{self.name} <#{self.email}>"
  end

  def has_flailed_signup?
    self.confirmed? && ( self.name.nil? || self.name.empty? )
  end

  def has_ordered_ticket?
    self.tickets.detect { |t| t.on_order? }.nil? ? false : true
  end

  def has_ordered_ticket_by_punter?(punter)
    self.tickets.detect { |t| t.order.owner == punter }.nil? ? false : true
  end

  def has_paid_ticket?
    self.tickets.detect { |t| t.paid? }.nil? ? false : true
  end

  def invite_if_necessary
    if self.confirmed?
      raise(PunterException, "#{self.name_with_email} has already accepted an invitation.")
    end

    unless self.confirmed? or self.rejected?
      self.invite!
    end
  end

  def name_with_email
    self.email_with_name
  end

  def paid_ticket_candidates
    self.all_ticket_candidates.find_all { |p| p.has_paid_ticket? }
  end

  def set_password
    if self.set_new_password
      salt = Punter.random_salt
      self.salt = salt
      self.salted_password = Punter.to_hash(salt + @password)
    end
  end

  def reset!
    self.send_invitation
  end

  def set_password!
    self.set_password
    self.save!
  end
                     
  def set_token!
    update_attribute(:authentication_token, Punter.to_hash(Punter.random_salt + self.email, 15))
    update_attribute(:salt, '')
    update_attribute(:salted_password, '')
  end

  def unpaid_ticket_candidates
    self.all_ticket_candidates.find_all { |p| !p.has_paid_ticket? }
  end

  def validate
    if self.email
      errors.add :email, "doesn't look like a proper email address" unless RFC822::EmailAddress.match(self.email)
    end
    
   if self.validate_password? && @password != @password_confirmation # could both be nil
     errors.add :password, "doesn't match the confirmation"
   end
  end

  def validate_password?
    self.set_new_password 
  end

  def validate_unique_email?
    true unless self.non_unique_email
  end

  def self.authenticate_by_password(email, password)
    email.downcase!
    punter = Punter.find_by_email(email)
    raise(PunterException, 'Login failed') if punter.nil?
    punter = Punter.find_by_email_and_salted_password(email, Punter.to_hash(punter.salt + password))
    raise(PunterException, 'Login failed') if punter.nil?

    punter.update_attribute(:last_login, Time.now)
    punter
  end

  def self.authenticate_by_token(token)
    punter = Punter.find_by_authentication_token(token)
    raise(PunterException, 'Login failed') if punter.nil? || punter.authentication_token != token

    punter.update_attribute(:authentication_token, nil)
    punter.update_attribute(:last_login, Time.now)
    punter
  end

  # used to for script-based inviting of people when you don't know their name
  # their state remains 'new', and they are forced to set a name when they confirm
  def self.invite_without_name(email)
    punter = Punter.create(:email => email, :name => 'foobar')
    punter.inviters << Site::Config.root_user
    punter.save! # will validate email uniqueness etc
    punter.update_attribute(:name, nil)
    punter.invite! # will return false owing to :name validation failure
    punter
  end

  protected

  def send_invitation
    self.set_token!
    Notifier.deliver_invitation(self)
  end

  def self.to_hash(plain, length = 62)
    return Digest::SHA1.hexdigest("#{SITE_SALT}-#{plain}")[0 .. length]
  end    

  def self.random_salt
    [Array.new(6){rand(256).chr}.join].pack("m").chomp
  end
end

