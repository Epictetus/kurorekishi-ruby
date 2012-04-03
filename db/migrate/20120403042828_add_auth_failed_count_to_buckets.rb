class AddAuthFailedCountToBuckets < ActiveRecord::Migration
  def change
    add_column :buckets, :auth_failed_count, :integer, :default => 0
  end
end
