source 'https://rubygems.org'

gem 'rails', '3.2.2'
gem 'mysql2'
gem 'resque', :git => 'git://github.com/defunkt/resque.git'
gem 'resque-scheduler', :require => 'resque_scheduler'
gem 'daemon-spawn', :require => 'daemon_spawn'
gem 'configatron'
gem 'net-netrc', :require => 'net/netrc'
gem 'exception_notification'

group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'
  gem 'uglifier', '>= 1.0.3'
end

gem 'jquery-rails'

group :development do
  gem 'annotate', :git => 'git://github.com/ctran/annotate_models.git'
end

group :production do
  gem 'unicorn'
end
