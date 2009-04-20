class AddPaypalLog < ActiveRecord::Migration
  def self.up
    create_table "paypal_logs", :force => true do |t|
      t.column "created_at", :datetime
      t.column "item_number", :integer
      t.column "quantity", :integer
      t.column "txn_id", :string, :limit => 128
      t.column "receiver_id", :string, :limit => 128
      t.column "payer_id", :string, :limit => 128
      t.column "payment_status", :string, :limit => 128
      t.column "mc_gross", :float
      t.column "mc_fee", :float
      t.column "invoice", :string, :limit => 128
      t.column "mc_currency", :string, :limit => 128

      t.timestamps
    end
  end

  def self.down
    drop_table "paypal_logs"
  end
end
