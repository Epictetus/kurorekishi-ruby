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
  scope :regulated, where('reset_at IS NOT NULL')
  scope :not_regulated, where('reset_at IS NULL')
  scope :completed, where('page => 160')
  scope :not_completed, where('page < 160')
  scope :auth_failed, where('auth_failed_count > 3')
  scope :auth_not_failed, where('auth_failed_count <= 3')
  scope :faraway, order('updated_at')

  ############################################################################

  def self.next_job
    Bucket.not_regulated.not_completed.auth_not_failed.faraway.first
  end

  def self.deregulation_jobs
    Bucket.where(['reset_at <= ?', DateTime.now])
  end

  def self.expired_jobs
    Bucket.where('created_at < DATE_ADD(NOW(), INTERVAL -2 DAY)')
  end

  ############################################################################

  def count_active_job
    Bucket.not_completed.auth_not_failed.count
  end

  def self.busyness
    job = Bucket.next_job
    if job.blank? || job.updated_at >= 5.minutes.ago
      busyness = '空き'
    elsif job.updated_at >= 10.minutes.ago
      busyness = '普通'
    else
      busyness = '混雑'
    end
    busyness
  end

  ############################################################################

  def touch!
    update_attributes!({ :updated_at => DateTime.now })
  end

  def regulate!(reset_time)
    update_attributes!({ :reset_at => reset_time })
  end

  def deregulate!
    update_attributes!({ :reset_at => nil })
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
