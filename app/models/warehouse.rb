
class Warehouse < ActiveRecord::Base
  serialize :statuses

  ############################################################################
  scope :crawl_jobs, where(['reset_at IS NULL OR reset_at <= ?', DateTime.now])
  scope :auth_failed, where('auth_failed_count > 3')
  scope :auth_not_failed, where('auth_failed_count <= 3')
  scope :faraway, order('updated_at')
end
