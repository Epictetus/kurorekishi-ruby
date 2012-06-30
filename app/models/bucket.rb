# -*- encoding: utf-8 -*-

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
#  auth_failed_count :integer(4)      default(0)
#
# Indexes
#
#  index_buckets_on_serial  (serial) UNIQUE
#

class Bucket < ActiveRecord::Base
  ############################################################################
  scope :active_jobs, lambda {
    where(['reset_at IS NULL AND max_id > 0 AND auth_failed_count <= 3']).order('id')
  }
  scope :inactive_jobs, lambda {
    where(['reset_at IS NOT NULL AND max_id > 0 AND auth_failed_count <= 3']).order('id')
  }
  scope :expired, where('created_at < DATE_ADD(NOW(), INTERVAL -2 DAY)')

  ############################################################################

  def self.count_job
    Bucket.where('auth_failed_count <= 3').count
  end

  def self.busyness
    busyness = ''
    if Bucket.count_job <= 75
      busyness = '空き'
    elsif Bucket.count_job <= 150
      busyness = '普通'
    else
      busyness = '混雑'
    end
    busyness
  end

  ############################################################################

  def done?
    page > 160
  end

  def elapsed_time
    '%sH' % ((Time.now - created_at.to_time) / (60 * 60)).truncate
  end

  ############################################################################

end
