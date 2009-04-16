class CreateRootUser < ActiveRecord::Migration
  def self.up
    current_punters = Punter.find(:all)
    root = Punter.create!(:email => 'site@thelongestday.net', :name => 'The Longest Day')
    current_punters.each do |punter|
      if punter.inviters.empty?
        Invitation.create!(:inviter =>  root, :invitee => punter)
      end
    end
  end

  def self.down
    tld = Punter.find_by_email('site@thelongestday.net')
    tld.destroy
  end
end
