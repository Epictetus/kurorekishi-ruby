# == Schema Information
#
# Table name: stats
#
#  id            :integer          not null, primary key
#  destroy_count :integer          default(0)
#  users         :text(16777215)
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

require 'spec_helper'

describe Stats do
  let(:stats)    { Array.new }

  describe '#fetch' do
    context 'initialized' do
      let(:stats) { FactoryGirl.create(:stats) }
      subject { Stats.fetch }
      it { should_not be_nil  }
    end

    context 'uninitialized' do
      subject { Stats.fetch }
      it { should_not be_nil  }
    end
  end

  context '#store' do
    context 'initialized' do
      let(:stats) { FactoryGirl.create(:stats) }
      subject { Stats.store!('14186100', 128) }
      it { should == true  }
    end

    context 'uninitialized' do
      subject { Stats.store!('14186100', 128) }
      it { should == true  }
    end

    context 'inclemented destroy and users count' do
      let(:stats) { FactoryGirl.create(:stats) }
      before do
        Stats.store!('14186100', 128)
        Stats.store!('14186101', 128)
      end
      subject { Stats.fetch }
      it { should == { :destroy_count => 256, :users_count => 2 } }
    end

    context 'users_count is total number' do
      let(:stats) { FactoryGirl.create(:stats) }
      before do
        Stats.store!('14186100', 128)
        Stats.store!('14186100', 128)
      end
      subject { Stats.fetch }
      it { should == { :destroy_count => 256, :users_count => 1 } }
    end
  end
end
