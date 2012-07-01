# -*- encoding: utf-8 -*-

# == Schema Information
#
# Table name: buckets
#
#  id                :integer          not null, primary key
#  serial            :string(255)      not null
#  token             :string(255)      not null
#  secret            :string(255)      not null
#  max_id            :string(255)
#  page              :integer          default(0)
#  destroy_count     :integer          default(0)
#  reset_at          :datetime
#  auth_failed_count :integer          default(0)
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#
# Indexes
#
#  index_buckets_on_serial  (serial) UNIQUE
#

class Bucket < ActiveRecord::Base
  ############################################################################
  scope :active_jobs, lambda {
    where(['reset_at IS NULL AND page < 200 AND max_id > 0 AND auth_failed_count <= 3']).order('updated_at')
  }
  scope :inactive_jobs, lambda {
    where(['reset_at IS NOT NULL AND max_id > 0 AND auth_failed_count <= 3']).order('updated_at')
  }
  scope :expired, where('created_at < DATE_ADD(NOW(), INTERVAL -2 DAY)')

  ############################################################################

  def self.count_job
    Bucket.where('auth_failed_count <= 3').count
  end

  def self.busyness
    job = Bucket.active_jobs.order('updated_at DESC').first
    if job.blank? || job.updated_at >= 7.minutes.ago
      busyness = '空き'
    elsif job.updated_at >= 14.minutes.ago
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

  def reseted_time
    '@%sM' % (reset_at.present? ? ((reset_at.to_time - Time.now) / 60).truncate : 0)
  end

  ############################################################################

end
