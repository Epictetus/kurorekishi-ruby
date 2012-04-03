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
  scope :jobs, lambda {
    c1 = 'last_processed_at IS NULL'
    c2 = 'last_processed_at < DATE_ADD(NOW(), INTERVAL -4 MINUTE)'
    c3 = 'page <= 160'
    c4 = 'auth_failed_count <= 3'
    where("(#{c1} OR #{c2}) AND #{c3} AND #{c4}").order('last_processed_at, id')
  }
  scope :expired, where('created_at < DATE_ADD(NOW(), INTERVAL -2 DAY)')

  ############################################################################

  def done?
    page > 160
  end

  def elapsed_time
    '%sH' % ((Time.now - created_at.to_time) / (60 * 60)).truncate
  end

  ############################################################################

end
