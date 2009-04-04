class CreatePunters < ActiveRecord::Migration
  def self.up
    create_table :punters do |t|
      t.string :name
      t.string :email
      t.string :state

      t.timestamps
    end
  end

  def self.down
    drop_table :punters
  end
end
