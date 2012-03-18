class CreateBuckets < ActiveRecord::Migration
  def change
    create_table :buckets do |t|
      t.string   :serial, :null => false
      t.string   :token,  :null => false
      t.string   :secret, :null => false
      t.integer  :page, :default => 1
      t.string   :max_id
      t.integer  :destroy_count, :default => 0
      t.datetime :last_processed_at

      t.timestamps
    end
    add_index :buckets, :serial, :unique => true
  end
end
