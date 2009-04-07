class AddAdminToPunter < ActiveRecord::Migration
  def self.up
    add_column :punters, :admin, :boolean, :default => false
  end

  def self.down
    remove_column :punters, :admin
  end
end
