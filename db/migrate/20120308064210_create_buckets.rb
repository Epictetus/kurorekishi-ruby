class CreateBuckets < ActiveRecord::Migration
  def change
    create_table :buckets do |t|
      t.string   :serial, :null => false
      t.string   :token,  :null => false
      t.string   :secret, :null => false
      t.string   :max_id, :null => false, :default => '0'
      t.integer  :page, :default => 0
      t.integer  :destroy_count, :default => 0
      t.datetime :reset_at
      t.integer  :auth_failed_count, :default => 0

      t.timestamps
    end
    add_index :buckets, :serial, :unique => true
  end
end
