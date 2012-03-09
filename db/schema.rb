# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20120308070030) do

  create_table "buckets", :force => true do |t|
    t.string   "serial",                         :null => false
    t.string   "token",                          :null => false
    t.string   "secret",                         :null => false
    t.integer  "destroy_count",   :default => 0
    t.datetime "last_touched_at",                :null => false
    t.datetime "created_at",                     :null => false
    t.datetime "updated_at",                     :null => false
  end

  add_index "buckets", ["serial"], :name => "index_buckets_on_serial"

  create_table "stats", :force => true do |t|
    t.integer  "destroy_count",                     :default => 0
    t.text     "users",         :limit => 16777215
    t.datetime "created_at",                                       :null => false
    t.datetime "updated_at",                                       :null => false
  end

end
