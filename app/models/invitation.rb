class Invitation < ActiveRecord::Base
  belongs_to :invitee, :foreign_key => 'invitee_id', :class_name => 'Punter'
  belongs_to :inviter, :foreign_key => 'inviter_id', :class_name => 'Punter'

  validates_presence_of :invitee
  validates_presence_of :inviter

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
    invitee = Punter.find_by_email(invitee_email)
    if invitee.nil?
      invitee = Punter.create!(:name => invitee_name, :email => invitee_email)
    end
    invite = Invitation.create(:inviter => inviter, :invitee => invitee)
  end

end
