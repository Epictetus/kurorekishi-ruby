
# app
Rails.application.routes.default_url_options[:host]= 'kurorekishi.yabasoft.biz'

# twitter
configatron.twitter.customer_key   = 'EfyBrxvjIq4HptaLhkPPg'
configatron.twitter.password       = '<your customer secret>'
configatron.twitter.oauth_callback = { :oauth_callback => 'http://kurorekishi.yabasoft.biz/oauth_callback' }
