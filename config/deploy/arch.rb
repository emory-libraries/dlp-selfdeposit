# frozen_string_literal: true

server ENV['ARCH_SERVER_IP'], user: 'deploy', roles: [:web, :app, :db, :ubuntu]
set :stage, :ARCH
