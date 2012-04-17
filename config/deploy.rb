set  :application, 'kurorekishi'
role :web,   'web'
role :app,   'app'
role :db,    'app', :primary => true
role :batch, 'kurorekishi'

set :scm,         :git
set :user,        'app'
set :use_sudo,    false

set :branch,      'develop'
set :repository,  '/Users/cohakim/Dropbox/Projects/Rails/kurorekishi'
set :deploy_via,  :copy
set :deploy_to,   '/var/www/app/kurorekishi'

# for asset pipeline
set :normalize_asset_timestamps, false

# for bundler
require 'bundler/capistrano'
set :bundle_gemfile,  'Gemfile'
set :bundle_dir,      File.join(fetch(:shared_path), 'bundle')
set :bundle_flags,    '--quiet'
set :bundle_without,  [:development, :test]
set :bundle_cmd,      'bundle'
set :bundle_roles,    [:web]

# for container
namespace :web do
  task :restart, :roles => :web, :except => { :no_release => true } do
    run "touch #{current_path}/tmp/restart.txt"
  end
  task :precompile, :roles => :web, :except => { :no_release => true } do
    run "cd #{current_path} && bundle exec rake assets:precompile"
  end
end

# for kurorekishi batches
namespace :batch do
  task :start, :roles => :batch do
    run "cd #{current_path} && RAILS_ENV=#{rails_env} script/resque_tweet_bot start"
    run "cd #{current_path} && RAILS_ENV=#{rails_env} script/resque_cleaner start"
  end
  task :stop, :roles => :batch do
    run "cd #{current_path} && script/resque_cleaner stop"
    run "cd #{current_path} && script/resque_tweet_bot stop"
  end
  task :restart, :roles => :batch do
    stop
    start
  end
end

after 'deploy:create_symlink' do
  # assets
  run "mkdir -p #{shared_path}/assets"
  run "ln -s #{shared_path}/assets #{release_path}/public/assets"
end
