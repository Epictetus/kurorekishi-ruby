# == Schema Information
#
# Table name: buckets
#
#  id                :integer(4)      not null, primary key
#  serial            :string(255)     not null
#  token             :string(255)     not null
#  secret            :string(255)     not null
#  expired_at        :datetime        not null
#  page              :integer(4)      default(1)
#  max_id            :string(255)
#  destroy_count     :integer(4)      default(0)
#  last_processed_at :datetime
#  created_at        :datetime        not null
#  updated_at        :datetime        not null
#
# Indexes
#
#  index_buckets_on_serial  (serial)
#

class Bucket < ActiveRecord::Base
  ############################################################################
  scope :jobs, lambda {
    c1 = 'last_processed_at IS NULL'
    c2 = 'last_processed_at < DATE_ADD(NOW(), INTERVAL -4 MINUTE)'
    where("#{c1} OR #{c2}").order('last_processed_at, id')
  }

  ############################################################################

  def done?
    page > 160
  end

  def expired?
    DateTime.now >= expired_at
  end

  def rest
    '@%sH' % ((expired_at.to_time - Time.now) / (60 * 60)).ceil
  end

  ############################################################################

end
