# == Schema Information
#
# Table name: stats
#
#  id            :integer(4)      not null, primary key
#  destroy_count :integer(4)      default(0)
#  users         :text(16777215)
#  created_at    :datetime        not null
#  updated_at    :datetime        not null
#

class Stats < ActiveRecord::Base
  serialize :users

  ############################################################################
  def self.store!(user, count)
    stats = find_or_create_by_id(1)
    stats.users ||= Array.new
    stats.users << user unless stats.users.include?(user)
    stats.destroy_count += count
    stats.save!
  end
end
