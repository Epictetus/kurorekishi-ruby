source 'https://rubygems.org'

gem 'rails', '3.2.2'
gem 'mysql2'
gem 'resque', :git => 'git://github.com/defunkt/resque.git'
gem 'resque-scheduler', :require => 'resque_scheduler'
gem 'daemon-spawn', :require => 'daemon_spawn'
gem 'configatron'
gem 'net-netrc', :require => 'net/netrc'
gem 'exception_notification'

gem 'twitter'
gem 'oauth'

gem 'jquery-rails'
gem 'haml'

group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'
  gem 'uglifier',     '>= 1.0.3'
  gem 'twitter-bootstrap-rails'
end

group :development do
  gem 'annotate', :git => 'git://github.com/ctran/annotate_models.git'
end

group :development, :test do
  gem 'rspec-rails'
  gem 'spork'
  gem 'guard-spork'
  gem 'guard-rspec'
  gem 'rb-fsevent'
  gem 'factory_girl_rails'
  gem 'simplecov', :require => false
  #gem 'ci_reporter', :require => 'ci/reporter/rake/rspec'
  gem 'growl'
  gem 'turn', '~> 0.8.3', :require => false
end
