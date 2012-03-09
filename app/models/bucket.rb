# == Schema Information
#
# Table name: buckets
#
#  id              :integer(4)      not null, primary key
#  serial          :string(255)     not null
#  token           :string(255)     not null
#  secret          :string(255)     not null
#  destroy_count   :integer(4)      default(0)
#  last_touched_at :datetime        not null
#  created_at      :datetime        not null
#  updated_at      :datetime        not null
#
# Indexes
#
#  index_buckets_on_serial  (serial)
#


class Bucket < ActiveRecord::Base
  JOB_EXPIRED = 12

  ############################################################################

  def expired?
    last_touched_at.plus_with_duration(JOB_EXPIRED * 60 * 60) <= DateTime.now
  end

  def expired_at
    '@%sH' % (JOB_EXPIRED - (Time.now - last_touched_at.to_time) / (60 * 60)).ceil
  end

  ############################################################################

end
