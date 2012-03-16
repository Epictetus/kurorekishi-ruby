class CreatePrtools < ActiveRecord::Migration
  def change
    create_table :prtools do |t|
      t.string :context, :null => false
      t.text   :users

      t.timestamps
    end
    execute "ALTER TABLE prtools MODIFY COLUMN users MEDIUMTEXT"
  end
end
