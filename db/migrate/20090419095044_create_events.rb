class CreateEvents < ActiveRecord::Migration
  def self.up
    create_table :events do |t|
      t.string :name
      t.integer :cost

      t.timestamps
    end
    Event.create!(:name => 'The Longest Day 2009', :cost => 4000)
  end

  def self.down
    drop_table :events
  end
end
