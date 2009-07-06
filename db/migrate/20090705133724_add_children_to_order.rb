class AddChildrenToOrder < ActiveRecord::Migration
  def self.up
    add_column :orders, :children, :integer, :default => 0
  end

  def self.down
    remove_column :orders, :children
  end
end
