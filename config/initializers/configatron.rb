Configatron::Rails.init

configatron.redis.password          = Net::Netrc.locate('redis').password
configatron.twitter.consumer_secret = Net::Netrc.locate('kurorekishi_twitter_consumer_secret').password
configatron.prtools.twitter.consumer_secret     = Net::Netrc.locate('prtools_twitter_consumer_secret').password
configatron.prtools.twitter.access_token_secret = Net::Netrc.locate('prtools_twitter_access_token_secret').password
