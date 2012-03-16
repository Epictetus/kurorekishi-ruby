
class Clean
  @queue = :cleaner

  def self.perform
    # 期限切れジョブの削除 -------------------------------------------------------------
    Bucket.expired.each do |job|
      job.destroy()
    end

    # ツイート削除処理 ---------------------------------------------------------------
    job = Bucket.jobs.first
    if job.blank? then return end

    # 最終処理日時を更新
    job.update_attribute(:last_processed_at, DateTime.now)

    # twitter client取得
    twitter = twitter_client(job.token, job.secret)

    # API残確認
    rest = twitter.rate_limit_status['remaining_hits']
    if rest <= 20 then return end

    # 処理対象のタイムライン取得
    timeline = twitter.user_timeline(job.serial.to_i, {
      :page      => job.page,
      :max_id    => job.max_id.try(:to_i),
      :count     => 20,
      :trim_user => true,
    })

    # max_idの保存
    if job.max_id.blank? && timeline.present?
      job.update_attribute(:max_id, timeline.first.id)
      page = 1
    end

    begin
      # ツイート削除
      count = 0
      timeline.each do |status|
        twitter.status_destroy(status.id, { :trim_user => true })
        count += 1
        sleep(0.5)
      end
      job.increment!(:page, 1)
    ensure
      # 統計情報更新
      job.increment!(:destroy_count, count)
      Stats.store!(job.serial, count)
    end

    nil
  end

  ############################################################################
  protected

  def self.twitter_client(access_token, access_secret)
    Twitter.configure do |config|
      config.consumer_key       = configatron.twitter.customer_key
      config.consumer_secret    = configatron.twitter.consumer_secret
      config.oauth_token        = access_token
      config.oauth_token_secret = access_secret
    end
    Twitter.new
  end

end
