module Site
  module Config
    mattr_accessor :root_user, :event
    @@root_user = Punter.find_by_email('site@thelongestday.net') || Punter.create!(:name => 'The Longest Day', :email => 'site@thelongestday.net')
    @@event = Event.find_by_name('The Longest Day 2009') || Event.create(:name => 'The Longest Day 2009', :cost => 4000)
  end
end

