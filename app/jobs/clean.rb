
class Clean
  @queue = :cleaner

  def self.perform
    # 期限切れジョブの削除 -------------------------------------------------------------
    Bucket.expired_jobs.each{|job| job.destroy }

    # API切れジョブのリセット ----------------------------------------------------------
    Bucket.deregulation_jobs.each{|job| job.deregulate! }

    # 処理対象ジョブ取得 --------------------------------------------------------------
    job = Bucket.next_job
    if job.blank? then return nil end
    job.touch!

    # 削除処理--------------------------------------------------------------------
    twitter = twitter_client(job.token, job.secret)

    begin
      # API制限の確認
      rate_limit_status = twitter.rate_limit_status

      if rate_limit_status[:remaining_hits] <= 35
        job.regulate!(rate_limit_status[:reset_time])
        return nil
      end

      # 処理対象のタイムライン取得
      timeline = twitter.user_timeline(job.serial.to_i, {
        :max_id      => [2**61, job.max_id.to_i].min,
        :count       => 30,
        :include_rts => true,
        :trim_user   => true,
      })

      if timeline.empty? then job.complete!; return nil end

      # ツイート削除
      destroy_count = 0
      ts = Array.new
      timeline.each do |status|
        ts << Thread.new do
          twitter.status_destroy(status.id)
          destroy_count += 1
        end
      end
      ts.each{|t| t.join }

    rescue Twitter::Error::Unauthorized => ex
      job.increment!(:auth_failed_count)
      raise ex
    end

    # 統計情報更新 -----------------------------------------------------------------
    job.increment!(:page)
    job.increment!(:destroy_count, destroy_count)
    Stats.store!(job.serial, destroy_count)

    nil
  end

  ############################################################################
  protected

  def self.twitter_client(access_token, access_secret)
    Twitter::Client.new({
      :consumer_key       => configatron.twitter.consumer_key,
      :consumer_secret    => configatron.twitter.consumer_secret,
      :oauth_token        => access_token,
      :oauth_token_secret => access_secret,
    })
  end

end
