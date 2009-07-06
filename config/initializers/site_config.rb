module Site
  module Config
    mattr_accessor :root_user, :signup_user, :event, :paypal, :admin_cost

    @@root_user   = Punter.find_by_email('site@thelongestday.net')   || Punter.create!(:name => 'The Longest Day', :email => 'site@thelongestday.net')
    @@signup_user = Punter.find_by_email('signup@thelongestday.net') || Punter.create!(:name => 'The Longest Day', :email => 'signup@thelongestday.net')
    @@event       = Event.find_by_name('The Longest Day 2009')       || Event.create!(:name => 'The Longest Day 2009', :cost => 4000)

    @@admin_cost = 2000

    if ENV['RAILS_ENV'] == 'production'
      Paypal::Notification.ipn_url = 'https://www.paypal.com/cgi-bin/webscr'
      Paypal::Notification.paypal_cert = File::read("#{CERT_DIR}/paypal_cert.pem")
      @@paypal = { :account => 'fat@lemonia.org', :certid => "HYEAFPK4CDKAU" }
    else
      @@paypal = { :account => 'tls-us_1240152369_biz@thelongestday.net', :certid => "79FERN55NWSHW" }
    end

    @@paypal[:key]  = File::read(File.join(CERT_DIR, 'tld_key.pem'))
    @@paypal[:cert] = File::read(File.join(CERT_DIR, 'tld_cert.pem'))
  end
end

