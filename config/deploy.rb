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

# for unicorn
set :rails_env, :production
set :unicorn_binary, 'bundle exec unicorn_rails'
set :unicorn_config, "#{current_path}/config/unicorn.rb"
set :unicorn_pid, "#{current_path}/tmp/pids/unicorn.pid"

namespace :web do
  task :start, :roles => :web, :except => { :no_release => true } do
    run "cd #{current_path} && #{try_sudo} #{unicorn_binary} -c #{unicorn_config} -E #{rails_env} -D"
  end
  task :stop, :roles => :web, :except => { :no_release => true } do
    run "#{try_sudo} kill `cat #{unicorn_pid}`"
  end
  task :reload, :roles => :web, :except => { :no_release => true } do
    run "#{try_sudo} kill -s USR2 `cat #{unicorn_pid}`"
  end
  task :restart, :roles => :web, :except => { :no_release => true } do
    stop
    start
  end
  task :precompile, :roles => :web, :except => { :no_release => true } do
    run "cd #{current_path} && bundle exec rake assets:precompile"
  end
end

# for kurorekishi batches
namespace :batch do
  task :start, :roles => :batch do
    run "cd #{current_path} && RAILS_ENV=#{rails_env} script/resque_cleaner start"
    run "cd #{current_path} && RAILS_ENV=#{rails_env} script/resque_scheduler start"
  end
  task :stop, :roles => :batch do
    run "cd #{current_path} && script/resque_scheduler stop"
    run "cd #{current_path} && script/resque_cleaner stop"
  end
  task :restart, :roles => :batch do
    stop
    start
  end
end

after 'deploy:create_symlink' do
  # unicorn
  run "mkdir -p #{shared_path}/sockets"
  run "ln -s #{shared_path}/sockets #{release_path}/tmp/sockets"
  # assets
  run "mkdir -p #{shared_path}/assets"
  run "ln -s #{shared_path}/assets #{release_path}/public/assets"
end
