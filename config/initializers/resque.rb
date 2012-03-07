require 'resque'
require 'resque/server'
require 'resque/scheduler'

rails_env = ENV['RAILS_ENV'] || 'development'
redis_config = YAML.load_file("#{Rails.root}/config/redis.yml")
Resque.redis = redis_config[rails_env]
Resque.redis.namespace = "kurorekishi:#{Rails.env}"
Resque.redis.client.password = configatron.redis.password
Resque.schedule = YAML.load_file("#{Rails.root}/config/schedule.yml")
