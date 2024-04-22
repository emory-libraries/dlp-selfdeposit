# frozen_string_literal: true

server ENV['TEST_SERVER_IP'], user: 'deploy', roles: [:web, :app, :db, :ubuntu]
set :stage, :TEST
