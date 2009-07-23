class AddSentFlagToOrder < ActiveRecord::Migration
  def self.up
    add_column :orders, :tickets_sent, :boolean, :default => false
  end

  def self.down
    remove_column :orders, :tickets_sent
  end
end
