class CreateInvitations < ActiveRecord::Migration
  def self.up
    create_table :invitations do |t|
      t.integer :inviter_id
      t.integer :invitee_id

      t.timestamps
    end
  end

  def self.down
    drop_table :invitations
  end
end
