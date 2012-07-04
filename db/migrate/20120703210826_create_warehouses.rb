class CreateWarehouses < ActiveRecord::Migration
  def change
    create_table :warehouses do |t|
      t.string   :serial, :null => false
      t.string   :token,  :null => false
      t.string   :secret, :null => false
      t.string   :since_id, :null => false, :default => '0'
      t.datetime :reset_at
      t.integer  :auth_failed_count, :default => 0
      t.text     :statuses

      t.timestamps
    end
    add_index :warehouses, :serial, :unique => true
    execute "ALTER TABLE warehouses MODIFY COLUMN statuses MEDIUMTEXT"
  end
end
