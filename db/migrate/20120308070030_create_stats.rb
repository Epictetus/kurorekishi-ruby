class CreateStats < ActiveRecord::Migration
  def change
    create_table :stats do |t|
      t.integer :destroy_count, :default => 0
      t.text    :users

      t.timestamps
    end
    execute "ALTER TABLE stats MODIFY COLUMN users MEDIUMTEXT"
  end
end
