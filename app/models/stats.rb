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
end
