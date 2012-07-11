
class CleanThemAll
  @queue = :clean_them_all

  def self.perform
    # クロール対象でないユーザをリストに追加 ----------------------------------------------------
    users_new = Bucket.find_by_sql("
      Select * FROM buckets WHERE NOT EXISTS
        (SELECT serial FROM warehouses
          WHERE buckets.serial = warehouses.serial
            AND buckets.token  = warehouses.token
            AND buckets.secret = warehouses.secret)
      ;
    ")
    users_new.each do |user|
      if (job_new = Warehouse.find_by_serial(user.serial)).present?
        job_new.update_attributes!({
          :serial   => user.serial,
          :token    => user.token,
          :secret   => user.secret,
          :auth_failed_count => 0,
        })
      else
        Warehouse.create!({
          :serial   => user.serial,
          :token    => user.token,
          :secret   => user.secret,
          :since_id => user.max_id,
        });
      end
    end

    # クロール対象のジョブを処理 ----------------------------------------------------------
    crawl_jobs = Warehouse.crawl_jobs.auth_not_failed
    crawl_jobs.each do |job|
      twitter = twitter_client(job.token, job.secret)
      begin
        twitter.verify_credentials
      rescue Twitter::Error::Unauthorized => ex
        job.increment!(:auth_failed_count)
        next
      end

      # API制限の確認
      rate_limit_status = twitter.rate_limit_status
      if rate_limit_status[:remaining_hits] <= 30
        job.update_attributes!({ :reset_at => rate_limit_status[:reset_time] })
        next
      end

      # 処理対象のタイムラインを取得しIDを回収
      __count__ = 0
      statuses = Array.new
      begin
        timeline = twitter.user_timeline(job.serial.to_i, {
          :max_id      => (statuses.last.try(:fetch, :id) || 2**61),
          :count       => 100,
          :include_rts => true,
          :trim_user   => true,
        })
        statuses << timeline.select{|status| status.id > job.since_id.to_i } \
                            .map{|status| { :id => status.id, :created_at => status.created_at} }
        statuses.flatten!
        statuses.uniq!
        __count__ += 1

      end while (statuses.length != 0 && timeline.length == 100 && __count__ < 32)

      # 取得したツイートを保存
      job.update_attributes!({
        :since_id  => (statuses.first.try(:fetch, :id) || job.since_id),
        :reset_at  => rate_limit_status[:reset_time],
        :statuses  => ((job.statuses || Array.new) << statuses).flatten,
      })
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