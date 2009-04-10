ActionMailer::Base.smtp_settings = {
    :address => RAILS_ENV == 'production' ? '172.16.1.254' : '127.0.0.1',
    :port    => 25,
    :domain  => 'thelongestday.net'
}

