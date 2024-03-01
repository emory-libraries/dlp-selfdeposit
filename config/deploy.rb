# config valid for current version and patch releases of Capistrano
lock "~> 3.18.0"

# Load environment variables
require 'dotenv'
Dotenv.load('.env.development')

# ======================================================
# Pre Deployment tasks
# ======================================================

namespace :deploy do
  desc 'Ask user for CAB approval before deployment if stage is PROD'
  task :confirm_cab_approval do
    if fetch(:stage) == :PROD
      ask(:cab_acknowledged, 'Have you submitted and received CAB approval? (Yes/No): ')
      unless /^y(es)?$/i.match?(fetch(:cab_acknowledged))
        puts 'Please submit a CAB request and get it approved before proceeding with deployment.'
        exit
      end
    end
  end
end

before 'deploy:starting', 'deploy:confirm_cab_approval'

# ======================================================
# Deployment Tasks
# ======================================================

set :application, "dlp-selfdeposit"
set :repo_url, "https://github.com/emory-libraries/dlp-selfdeposit"
set :deploy_to, '/opt/dlp-selfdeposit'

server ENV['ARCH_SERVER_IP'], user: 'deploy', roles: [:web, :app, :db, :ubuntu]

set :rbenv_ruby, '3.2.2'
set :rbenv_custom_path, '/usr/local/rbenv'
set :rails_env, 'production'
set :assets_prefix, "#{shared_path}/public/assets"
set :migration_role, :app
set :service_unit_name, "sidekiq.service"

SSHKit.config.command_map[:rake] = 'bundle exec rake'

set :branch, ENV['REVISION'] || ENV['BRANCH'] || ENV['BRANCH_NAME'] || 'main'

append :linked_dirs, "log", "public/assets", "tmp/pids", "tmp/cache", "tmp/sockets",
  "tmp/imports", "config/emory/groups", "tmp/csv_uploads", "tmp/csv_uploads_cache"

append :linked_files, ".env.production", "config/secrets.yml"

set :default_env,
    PATH:                            '$PATH:/usr/local/rbenv/shims/ruby',
    LD_LIBRARY_PATH:                 '$LD_LIBRARY_PATH:/usr/lib64',
    PASSENGER_INSTANCE_REGISTRY_DIR: '/var/run'

# Default value for local_user is ENV['USER']
set :local_user, -> { `git config user.name`.chomp }

# ======================================================
# Post Deployment Tasks
# ======================================================

# Restart apache
namespace :deploy do
  after :finishing, :restart_apache do
    on roles(:ubuntu) do
      execute :sudo, :systemctl, :restart, :httpd
    end
  end
end

# ======================================================
# Sidekiq Tasks
# ======================================================

namespace :sidekiq do
  task :restart do
    invoke 'sidekiq:stop'
    invoke 'sidekiq:start'
  end

  before 'deploy:finished', 'sidekiq:restart'

  task :stop do
    on roles(:app) do
      execute :sudo, :systemctl, :stop, :sidekiq
    end
  end

  task :start do
    on roles(:app) do
      execute :sudo, :systemctl, :start, :sidekiq
    end
  end
end
