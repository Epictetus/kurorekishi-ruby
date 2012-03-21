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

FactoryGirl.define do
  factory :stats do
    destroy_count      0
    users              nil
    created_at         { DateTime.now }
    updated_at         { DateTime.now }
  end
end