require 'regex'
require 'punter_exception'

class Punter < ActiveRecord::Base
  validates_presence_of :name, :email
  validates_uniqueness_of :email
  validates_length_of :name, :within => 6 .. 128
  validates_length_of :email, :maximum => 128

  attr_accessor :password, :password_confirmation, :set_new_password
  
  validates_presence_of :password, :if => :validate_password?
  validates_length_of :password, :within => 6 .. 64, :if => :validate_password?
  validates_confirmation_of :password, :if => :validate_password?

  include AASM

  aasm_column :state
  aasm_initial_state :new
  aasm_state :new
  aasm_state :invited, :enter => :send_invitation
  aasm_state :confirmed
  aasm_state :rejected

  aasm_event :invite do
    transitions :from => :new, :to => :invited
    transitions :from => :invited, :to => :invited
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

  def validate_password?
    self.set_new_password
  end

  def must_set_password?
    self.salt.nil?
  end

  def name_with_email
    self.email_with_name
  end

  def set_password!
    update_attribute(:salt, Punter.random_salt)
    update_attribute(:salted_password, Punter.to_hash(self.salt + @password))
    @password = nil
    @password_confirmation = nil
  end
                     
  def set_token!
    update_attribute(:authentication_token, Punter.to_hash(Punter.random_salt + self.email, 15))
    update_attribute(:salt, nil)
    update_attribute(:salted_password, 'unhashable')
  end

  def validate
    if self.email
      errors.add :email, "doesn't look like a proper email address" unless RFC822::EmailAddress.match(self.email)
    end
    
    if self.validate_password? && @password != @password_confirmation # could both be nil
      errors.add :password, "don't match"
      errors.add :password_confirmation, "don't match"
    end
  end

  def self.authenticate_by_password(email, password)
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

