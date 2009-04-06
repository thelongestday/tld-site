# For migrations
set :rails_env, 'production'

# Who are we?
set :application, 'tld-site'
set :repository, "git@github.com:thelongestday/#{application}.git"
set :scm, "git"
set :deploy_via, :remote_cache
set :branch, "production"

# Where to deploy to?
role :web, "www.thelongestday.net"
role :app, "www.thelongestday.net"
role :db,  "www.thelongestday.net", :primary => true

# Deploy details
set :user, "rails"
set :deploy_to, "/usr/local/www/rails/tld3"
set :use_sudo, false
set :checkout, 'export'

# We need to know how to use mongrel
set :mongrel_rails, '/usr/local/bin/mongrel_rails'
set :mongrel_cluster_config, "#{deploy_to}/#{current_dir}/config/mongrel_cluster_production.yml"
