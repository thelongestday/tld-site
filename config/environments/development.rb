# Settings specified here will take precedence over those in config/environment.rb

# In the development environment your application's code is reloaded on
# every request.  This slows down response time but is perfect for development
# since you don't have to restart the webserver when you make code changes.
config.cache_classes = false

# Log error messages when you accidentally call methods on nil.
config.whiny_nils = true

# Show full error reports and disable caching
config.action_controller.consider_all_requests_local = true
config.action_controller.perform_caching             = false
config.action_view.debug_rjs                         = true

# Don't care if the mailer can't send
config.action_mailer.raise_delivery_errors = false

config.action_mailer.default_url_options = { :host => 'localhost', :port=>3000 } 

HOST = 'localhost'

SALT_FILE = File.join(RAILS_ROOT, 'config', 'salt')  
SITE_SALT = File.read(SALT_FILE)
CERT_DIR = File.join(RAILS_ROOT, 'config', 'x509')

config.to_prepare do
  load("#{Rails.root}/config/initializers/site_config.rb")
end

ActionView::Base.send(:include, Paypal::Helpers)

