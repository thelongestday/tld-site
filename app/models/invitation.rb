class Invitation < ActiveRecord::Base
  belongs_to :punter, :foreign_key => 'inviter_id'
  belongs_to :punter, :foreign_key => 'invitee_id'
end
