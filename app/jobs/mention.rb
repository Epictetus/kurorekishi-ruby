# -*- encoding: utf-8 -*-

class Mention
  @queue = :tweet_bot

  def self.perform
    search_and_destroy('ツイート 全消し OR 全削除')
    search_and_destroy('ツイート 全部 OR 全て 消したい OR 削除 OR 消す')
    nil
  end

  protected

  def self.search_and_destroy(conditions)
    twitter = twitter_client
    prtool  = Prtool.find_or_create_by_context(:mention_destroy)
    begin
      tweets = Hash.new
      prtool.users ||= Hash.new
      twitter.search(conditions).each do |tweet|
        next if prtool.users.has_key?(tweet.from_user_id)
        twitter.update(
          "@#{tweet.from_user} ツイート一括削除ツール「黒歴史クリーナー」よかったら使ってください (>ω<) - http://kurorekishi.yabasoft.biz/ （このメッセージは自動投稿です。1ユーザにつき1度だけ投稿されます。）",
          { :in_reply_to_status_id => tweet.id, :trim_user => true }
        )
        tweets.store(tweet.from_user_id, tweet.id)
      end
    ensure
      prtool.attributes = {
        :context => :mention_destroy,
        :users   => prtool.users.merge(tweets)
      }
      prtool.save!
    end
    nil
  end

  def self.twitter_client
    Twitter.configure do |config|
      config.consumer_key       = configatron.prtools.twitter.customer_key
      config.consumer_secret    = configatron.prtools.twitter.consumer_secret
      config.oauth_token        = configatron.prtools.twitter.access_token
      config.oauth_token_secret = configatron.prtools.twitter.access_token_secret
    end
    Twitter.new
  end

end
