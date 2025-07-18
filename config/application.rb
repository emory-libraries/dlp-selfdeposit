# frozen_string_literal: true
require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module DlpSelfDeposit
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.0

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.
    config.session_store :cookie_store, key: "_#{ENV.fetch('APP_NAME', 'delp-selfdeposit')}_session"

    # use SideKiq by default
    config.active_job.queue_adapter = :sidekiq

    if ENV["RAILS_LOG_TO_STDOUT"]
      logger = ActiveSupport::Logger.new($stdout)
      logger.formatter = config.log_formatter
      config.logger = ActiveSupport::TaggedLogging.new(logger)
    end

    config.to_prepare do
      Hyrax::Dashboard::CollectionsController.prepend Hyrax::Dashboard::CollectionsControllerOverride
    end

    # The locale is set by a query parameter, so if it's not found render 404
    config.action_dispatch.rescue_responses['I18n::InvalidLocale'] = [:not_found, :internal_server_error, :unprocessable_entity]

    config.exceptions_app = routes
  end
end
