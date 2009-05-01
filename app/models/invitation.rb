class Invitation < ActiveRecord::Base
  belongs_to :invitee, :foreign_key => 'invitee_id', :class_name => 'Punter'
  belongs_to :inviter, :foreign_key => 'inviter_id', :class_name => 'Punter'

  validates_presence_of :invitee
  validates_presence_of :inviter

  validates_uniqueness_of :invitee_id, :scope => :inviter_id, :message => 'already invited by you'

  def self.inviters_for(invitee_email)
    invitee = Punter.find_by_email(invitee_email)
    return nil if invitee.nil?

    if invitee.inviters.empty?
      # invitee is invited, but we don't know why by, eep
      RAILS_DEFAULT_LOGGER.error("[Invitation] #{invitee_email} appears to be invited (#{invitee.id}) but don't know inviter")
    end
    return invitee.inviters
  end

  def self.invite_punter(inviter, invitee_email, invitee_name)
    if invitee_email == inviter.email
      raise(PunterException,'Inviting yourself is quite kinky! And not allowed.')
    end

    inviter.invitees.each do |ii|
      if ii.email == invitee_email
        raise(PunterException, "Hey, you've already invited #{ii.name_with_email}!")
      end
    end

    inviter.inviters.each do |ii|
      if ii.email == invitee_email
        raise(PunterException, "Hey, #{ii.name_with_email} invited you!")
      end
    end

    invitee = Punter.find_by_email(invitee_email)
    if invitee.nil?
      invitee = Punter.create!(:name => invitee_name, :email => invitee_email)
    end
    begin
      invite = Invitation.create!(:inviter => inviter, :invitee => invitee)
      invitee.invite_if_necessary
    rescue ActiveRecord::RecordInvalid
      raise PunterException
    end
  end

end
