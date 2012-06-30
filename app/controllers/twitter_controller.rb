class TwitterController < ApplicationController
  module TwitterModule
    def set_twitter_authorize_url
      consumer = consumer_from_configatron
      request_token = consumer.get_request_token(configatron.twitter.oauth_callback)
      session[:request_token] = request_token.token
      session[:request_token_secret] = request_token.secret
      @authorize_url = request_token.authorize_url
    end

    def set_twitter_access_token
      consumer = consumer_from_configatron
      request_token = request_token_from_session

      access_token = request_token.get_access_token(
        {},
        :oauth_token => params[:oauth_token],
        :oauth_verifier => params[:oauth_verifier]
      )
      session[:access_token] = access_token.token
      session[:access_token_secret] = access_token.secret
    end

    def set_user_profile
      if session[:user_profile].blank?
        twitter = twitter_from_session
        session[:user_profile] = {
          :twitter_id          => twitter.user.id,
          :twitter_screen_name => twitter.user.screen_name,
          :max_id              => (twitter.user_timeline.first.try(:id) || '0'),
          :access_token        => session[:access_token],
          :access_token_secret => session[:access_token_secret],
        }
      end
      @user_profile = session[:user_profile]
    end

    def twitter_from_session
      consumer = consumer_from_configatron
      access_token = access_token_from_session
      Twitter::Client.new({
        :consumer_key       => consumer.key,
        :consumer_secret    => consumer.secret,
        :oauth_token        => access_token.token,
        :oauth_token_secret => access_token.secret,
      })
    end

    def access_token_from_session
      OAuth::AccessToken.new(
        consumer_from_configatron,
        session[:access_token],
        session[:access_token_secret]
      )
    end

    def request_token_from_session
      OAuth::RequestToken.new(
        consumer_from_configatron,
        session[:request_token],
        session[:request_token_secret]
      )
    end

    def consumer_from_configatron
      OAuth::Consumer.new(
        configatron.twitter.consumer_key,
        configatron.twitter.consumer_secret,
        :site => 'http://twitter.com'
      )
    end
  end
end