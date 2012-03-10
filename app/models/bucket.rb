# == Schema Information
#
# Table name: buckets
#
#  id                :integer(4)      not null, primary key
#  serial            :string(255)     not null
#  token             :string(255)     not null
#  secret            :string(255)     not null
#  destroy_count     :integer(4)      default(0)
#  expired_at        :datetime        not null
#  last_processed_at :datetime
#  max_id            :string(255)
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

  def expired?
    DateTime.now >= expired_at
  end

  def rest
    # TODO: 処理を書く
    '@12H'
    #'@%sH' % ((expired_at.to_time - Time) / (60 * 60)).ceil
  end

  ############################################################################

end
