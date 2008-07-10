class CreateActiveSources < ActiveRecord::Migration
  def self.up
    create_table :active_sources do |t|
      t.timestamps
      t.string :uri, :null => false
      t.string :type
    end
  end

  def self.down
    drop_table :active_sources
  end
end
