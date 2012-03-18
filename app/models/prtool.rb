# == Schema Information
#
# Table name: prtools
#
#  id         :integer(4)      not null, primary key
#  context    :string(255)     not null
#  users      :text(16777215)
#  created_at :datetime        not null
#  updated_at :datetime        not null
#


class Prtool < ActiveRecord::Base
  serialize :users

end
