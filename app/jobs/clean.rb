
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

    # ツイート削除 -----------------------------------------------------------------
    results = Array.new

    ts = Array.new
    Bucket.active_jobs.each do |job|
      ts << Thread.new do
        twitter = twitter_client(job.token, job.secret)
        begin
          # API制限
          rate_limit_status = twitter.rate_limit_status
          if rate_limit_status[:remaining_hits] <= 30
            job.update_attributes!({ :reset_at => rate_limit_status[:reset_time] })
            next
          end

          # 処理対象のタイムライン取得
          timeline = twitter.user_timeline(job.serial.to_i, {
            :max_id      => [2**61, job.max_id.to_i].min,
            :count       => 20,
            :include_rts => true,
            :trim_user   => true,
          })

          # ツイート削除
          count = 0
          ts2 = Array.new
          timeline.each do |status|
            ts2 << Thread.new do
              twitter.status_destroy(status.id, { :trim_user => true })
              count += 1
            end
          end
          ts2.each{|t| t.join }

          # 統計情報保存
          results << { :job => job, :destroy_count => count }
        rescue Twitter::Error::Unauthorized => ex
          job.increment!(:auth_failed_count)
          raise ex
        end
      end
    end
    ts.each{|t| t.join }

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

  def self.twitter_client(access_token, access_secret)
    Twitter::Client.new({
      :consumer_key       => configatron.twitter.consumer_key,
      :consumer_secret    => configatron.twitter.consumer_secret,
      :oauth_token        => access_token,
      :oauth_token_secret => access_secret,
    })
  end

end
