class CreateBuckets < ActiveRecord::Migration
  def change
    create_table :buckets do |t|
      t.string   :serial, :null => false
      t.string   :token,  :null => false
      t.string   :secret, :null => false
      t.integer  :destroy_count, :default => '0'
      t.datetime :last_touched_at, :null => false

      t.timestamps
    end
    add_index :buckets, :serial
  end
end
