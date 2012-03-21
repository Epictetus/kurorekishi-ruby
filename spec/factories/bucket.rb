# == Schema Information
#
# Table name: buckets
#
#  id                :integer(4)      not null, primary key
#  serial            :string(255)     not null
#  token             :string(255)     not null
#  secret            :string(255)     not null
#  page              :integer(4)      default(1)
#  max_id            :string(255)
#  destroy_count     :integer(4)      default(0)
#  last_processed_at :datetime
#  created_at        :datetime        not null
#  updated_at        :datetime        not null
#
# Indexes
#
#  index_buckets_on_serial  (serial) UNIQUE
#

FactoryGirl.define do
  factory :created, :class => Bucket do
    sequence(:serial)  {|n| "100#{n}" }
    token              'token'
    secret             'secret'
    page               1
    max_id             nil
    destroy_count      0
    last_processed_at  nil
    created_at         { DateTime.now }
    updated_at         { DateTime.now }
  end

  factory :processing, :class => Bucket do
    sequence(:serial)  {|n| "200#{n}" }
    token              'token'
    secret             'secret'
    page               8
    max_id             '182363757203304448'
    destroy_count      128
    last_processed_at  { 5.minutes.ago }
    created_at         { 32.minutes.ago }
    updated_at         { 5.minutes.ago }
  end

  factory :finished, :class => Bucket do
    sequence(:serial)  {|n| "300#{n}" }
    token              'token'
    secret             'secret'
    page               161
    max_id             '182363757203304448'
    destroy_count      1024
    last_processed_at  { 5.minutes.ago }
    created_at         { 12.hours.ago }
    updated_at         { 5.minutes.ago }
  end

  factory :expired, :class => Bucket do
    sequence(:serial)  {|n| "400#{n}" }
    token              'token'
    secret             'secret'
    page               8
    max_id             '182363757203304448'
    destroy_count      128
    last_processed_at  { 1.days.ago }
    created_at         { 3.days.ago }
    updated_at         { 1.days.ago }
  end
end
