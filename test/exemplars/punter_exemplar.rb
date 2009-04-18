class Punter < ActiveRecord::Base
  generator_for :email, :start => 'test@example.com' do |prev|
    user, domain = prev.split('@')
    user.succ + '@' + domain
  end

  generator_for :name, :method => :next_user

  def self.next_user
    @last_username ||= 'testuser'
    @last_username.succ
  end
end  
