
class Clean
  @queue = :cleaner

  def self.perform
    # 期限切れジョブの削除 -------------------------------------------------------------
    Bucket.expired.each do |job|
      job.destroy
    end

    # API切れジョブのリセット ----------------------------------------------------------
    Bucket.inactive_jobs.each do |job|
      if job.reset_at <= DateTime.now
        job.update_attributes!({ :reset_at => nil })
      end
    end

    # TL取得 -------------------------------------------------------------------
    timelines = get_timelines

    # ツイート削除 -----------------------------------------------------------------
    results = destroy_timelines(timelines)

    # 統計情報更新 -----------------------------------------------------------------
    results.each do |result|
      result[:job].increment!(:page)
      result[:job].increment!(:destroy_count, result[:destroy_count])
      Stats.store!(result[:job].serial, result[:destroy_count])
    end

    nil
  end

  ############################################################################
  protected

  def self.destroy_timelines(timelines)
    results = Array.new

    timelines.each do |timeline|
      count = 0
      ts = Array.new
      timeline[:timeline].each do |status|
        ts << Thread.new do
          timeline[:twitter].status_destroy(status.id, { :trim_user => true })
          count += 1
        end
      end
      ts.each{|t| t.join }
      results << { :job => timeline[:job], :destroy_count => count }
    end

    results
  end

  def self.get_timelines
    timelines = Array.new

    ts = Array.new
    Bucket.active_jobs.limit(3).each do |job|
      job.update_attributes!({ :updated_at => DateTime.now })
      ts << Thread.new do
        begin
          twitter = twitter_client(job.token, job.secret)
          # API制限
          rate_limit_status = twitter.rate_limit_status
          if rate_limit_status[:remaining_hits] <= 30
            job.update_attributes!({ :reset_at => rate_limit_status[:reset_time] })
            next
          end

          # 処理対象のタイムライン取得
          timeline = twitter.user_timeline(job.serial.to_i, {
            :max_id      => [2**61, job.max_id.to_i].min,
            :count       => 50,
            :include_rts => true,
            :trim_user   => true,
          })

          timelines << { :job => job, :twitter => twitter, :timeline => timeline }
        rescue Twitter::Error::Unauthorized => ex
          job.increment!(:auth_failed_count)
          raise ex
        end
      end
    end
    ts.each{|t| t.join }

    timelines
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
