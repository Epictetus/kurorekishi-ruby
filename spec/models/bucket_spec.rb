# == Schema Information
#
# Table name: buckets
#
#  id                :integer(4)      not null, primary key
#  serial            :string(255)     not null
#  token             :string(255)     not null
#  secret            :string(255)     not null
#  page              :integer(4)      default(1)
#  max_id            :string(255)
#  destroy_count     :integer(4)      default(0)
#  last_processed_at :datetime
#  created_at        :datetime        not null
#  updated_at        :datetime        not null
#  auth_failed_count :integer(4)      default(0)
#
# Indexes
#
#  index_buckets_on_serial  (serial) UNIQUE
#

require 'spec_helper'

describe Bucket do
  let(:buckets)    { Array.new }

  describe 'scope#jobs' do
    context 'created' do
      let(:created) { FactoryGirl.create(:created) }
      before do
        buckets << created
      end
      subject { Bucket.jobs.first }
      it { should == created }
    end

    context 'processing' do
      let(:processing) { FactoryGirl.create(:processing) }
      before do
        buckets << processing
      end
      subject { Bucket.jobs.first }
      it { should == processing }
    end

    context 'finished' do
      let(:finished) { FactoryGirl.create(:finished) }
      before do
        buckets << finished
      end
      subject { Bucket.jobs.first }
      it { should == nil }
    end

    context 'expired' do
      let(:expired) { FactoryGirl.create(:expired) }
      before do
        buckets << expired
      end
      subject { Bucket.jobs.first }
      it { should == expired }
    end

    context 'interval 4 minutes' do
      let(:processing) { FactoryGirl.create(:processing, :last_processed_at => DateTime.now) }
      before do
        buckets << processing
      end
      subject { Bucket.jobs.first }
      it { should == nil }
    end

    context 'further' do
      let(:further) { FactoryGirl.create(:processing, :last_processed_at => 8.minutes.ago) }
      let(:nearer)  { FactoryGirl.create(:processing, :last_processed_at => 5.minutes.ago) }
      before do
        buckets << further << nearer
      end
      subject { Bucket.jobs.first }
      it { should == further }
    end
  end

  context 'scope#expired' do
    let(:created)    { FactoryGirl.create(:created) }
    let(:processing) { FactoryGirl.create(:processing) }
    let(:finished)   { FactoryGirl.create(:finished) }
    let(:expired)    { FactoryGirl.create(:expired) }
    before do
      buckets << created << processing << finished << expired
    end
    subject { Bucket.expired.first }
    it { should == expired }
  end

  context '.done?' do
    let(:finished)     { FactoryGirl.create(:finished) }
    let(:not_finished) { FactoryGirl.create(:finished, :page => 160) }
    subject { [finished.done?, not_finished.done?] }
    it { should == [true, false] }
  end

  context '.elapsed_time' do
    let(:h1)  { FactoryGirl.create(:processing, :created_at => 1.hours.ago) }
    let(:h24) { FactoryGirl.create(:processing, :created_at => 1.days.ago) }
    subject { [h1.elapsed_time, h24.elapsed_time] }
    it { should == ['1H', '24H'] }
  end
end
