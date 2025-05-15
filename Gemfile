# frozen_string_literal: true

source 'https://rubygems.org'

ruby '~> 3.4.0'

gem 'aws-sdk-secretsmanager'
gem 'bootsnap', '>= 1.1.0', require: false
gem 'bootstrap', '~> 4.6'
gem 'bulkrax', '~> 8.2.0'
gem 'coffee-rails', '~> 4.2'
gem 'concurrent-ruby', '1.3.4'
gem 'dalli'
gem 'devise'
gem 'devise-guests', '~> 0.8'
gem 'dotenv-rails'
gem 'hydra-role-management'
gem 'hyrax', git: 'https://github.com/samvera/hyrax', ref: '9c58751'
gem 'jbuilder', '~> 2.5'
gem 'jquery-rails'
gem 'mutex_m', '~> 0.2.0'
gem 'omniauth-rails_csrf_protection'
gem 'omniauth-saml'
gem 'pg', '~> 1.3'
gem 'puma'
gem 'rails', '~> 6.1'
gem 'riiif', '~> 2.1'
gem 'rsolr', '>= 1.0', '< 3'
gem 'sass-rails', '~> 6.0'
gem 'sidekiq', '~> 6.4'
gem 'turbolinks', '~> 5'
gem 'twitter-typeahead-rails', '0.11.1'
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
gem 'uglifier', '>= 1.3.0'
gem 'whenever', require: false

group :development do
  # Add command line in browser when errors
  gem 'better_errors'

  # Add deeper stack trace used by better errors
  gem 'binding_of_caller'

  # Add deployment tools
  gem 'bcrypt_pbkdf', '>= 1.0', '< 2.0'
  gem "capistrano", require: false
  gem 'capistrano-bundler', '~> 1.3', require: false
  gem "capistrano-rails", "~> 1.6", require: false
  gem 'capistrano-rbenv', '~> 2.2', require: false
  gem 'ec2_ipv4_retriever', git: 'https://github.com/emory-libraries/ec2_ipv4_retriever', branch: 'main'
  gem 'ed25519', '>= 1.2', '< 2.0'

  # Access an interactive console on exception pages or by calling 'console' anywhere in the code
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'web-console', '>= 3.3.0'

  # Spring speeds up development by keeping your application running in the background
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'

  # Add inspection tool for frontend
  gem "xray-rails", git: "https://github.com/brentd/xray-rails", branch: "bugs/ruby-3.0.0"
end

group :development, :test do
  gem 'bixby'
  gem 'capybara-screenshot'
  gem 'coveralls', require: false
  gem 'debug', '>= 1.0.0'
  gem 'factory_bot_rails'
  gem 'pry-doc'
  gem 'pry-rails'
  gem 'pry-rescue'
  gem 'rails-controller-testing'
  gem 'rspec-activemodel-mocks'
  gem 'rspec-rails'
  gem 'rubocop', require: false
  gem 'rubocop-capybara', require: false
  gem 'rubocop-rails', require: false
  gem 'rubocop-rspec', require: false
  gem 'selenium-webdriver', '~> 4.4'
end

group :test do
  gem 'capybara'
  gem 'rspec_junit_formatter'
end
