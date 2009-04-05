class AddAuthenticationToPunter < ActiveRecord::Migration
  def self.up
    add_column :punters, :salt, :string, :limit => 64
    add_column :punters, :salted_password, :string, :limit => 64
    add_column :punters, :authentication_token, :string, :limit => 16
    add_column :punters, :last_login, :datetime
  end

  def self.down
    remove_column :punters, :last_login
    remove_column :punters, :authentication_token
    remove_column :punters, :salted_password
    remove_column :punters, :salt
  end
end
