
class Bucket < ActiveRecord::Base

  def expired_at
    '@%sH' % (12 - (Time.now - last_touched_at.to_time) / (60 * 60)).ceil
  end

end
