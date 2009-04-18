class CreateTickets < ActiveRecord::Migration
  def self.up
    create_table :tickets do |t|
      t.integer :punter_id
      t.integer :order_id
      t.integer :cost

      t.timestamps
    end
  end

  def self.down
    drop_table :tickets
  end
end
