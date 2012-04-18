
set :environment, 'production'
set :output, { :error => 'log/error.log', :standard => 'log/cron.log' }

every 5.minutes do
  runner 'Mention.perform'
end
