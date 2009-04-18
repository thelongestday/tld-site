class CreateOrders < ActiveRecord::Migration
  def self.up
    create_table :orders do |t|
      t.integer :owner_id
      t.string :state
      t.integer :money_received

      t.timestamps
    end
  end

  def self.down
    drop_table :orders
  end
end
