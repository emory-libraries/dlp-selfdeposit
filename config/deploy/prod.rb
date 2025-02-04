# frozen_string_literal: true

server ENV['PROD_SERVER_IP'], user: 'deploy', roles: [:web, :app, :db, :ubuntu]
set :stage, :PROD
