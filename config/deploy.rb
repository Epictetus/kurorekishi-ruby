set  :application, 'kurorekishi'
role :web, 'kurorekishi'
role :app, 'kurorekishi'
role :db,  'kurorekishi', :primary => true

set :scm,         :git
set :user,        "app"
set :use_sudo,    false

set :branch,      'develop'
set :repository,  "/Users/cohakim/Dropbox/Projects/Rails/kurorekishi"
set :deploy_via,  :copy
set :deploy_to,   "/var/www/app/kurorekishi"

# for asset pipeline
set :normalize_asset_timestamps, false

# for bundler
require "bundler/capistrano"
set :bundle_gemfile,  "Gemfile"
set :bundle_dir,      File.join(fetch(:shared_path), 'bundle')
set :bundle_flags,    "--quiet"
set :bundle_without,  [:development, :test]
set :bundle_cmd,      "bundle"
set :bundle_roles,    [:app]

# for unicorn
set :rails_env, :production
set :unicorn_binary, "bundle exec unicorn_rails"
set :unicorn_config, "#{current_path}/config/unicorn.rb"
set :unicorn_pid, "#{current_path}/tmp/pids/unicorn.pid"

namespace :app do
  task :start, :roles => :app, :except => { :no_release => true } do
    run "cd #{current_path} && #{try_sudo} #{unicorn_binary} -c #{unicorn_config} -E #{rails_env} -D"
  end
  task :stop, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} kill `cat #{unicorn_pid}`"
  end
  task :graceful_stop, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} kill -s QUIT `cat #{unicorn_pid}`"
  end
  task :reload, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} kill -s USR2 `cat #{unicorn_pid}`"
  end
  task :restart, :roles => :app, :except => { :no_release => true } do
    stop
    start
  end
end

after 'deploy:symlink' do
  run "mkdir -p #{current_path}/tmp"
  # unicorn
  run "mkdir -p #{shared_path}/sockets"
  run "ln -s #{shared_path}/sockets #{current_path}/tmp/sockets"
  # assets
  run "mkdir -p #{shared_path}/assets"
  run "ln -s #{shared_path}/assets #{current_path}/public/assets"
end
