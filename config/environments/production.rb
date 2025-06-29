# frozen_string_literal: true
Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # Code is not reloaded between requests.
  config.cache_classes = true

  # Eager load code on boot. This eager loads most of Rails and
  # your application in memory, allowing both threaded web servers
  # and those relying on copy on write to perform better.
  # Rake tasks automatically ignore this option for performance.
  config.eager_load = true

  # Full error reports are disabled and caching is turned on.
  # To display stack traces in production, you want
  # config.consider_all_requests_local       = true
  # To hide stack traces in production, set this to false.
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true

  # Ensures that a master key has been made available in either ENV["RAILS_MASTER_KEY"]
  # or in config/master.key. This key is used to decrypt credentials (and other encrypted files).
  # config.require_master_key = true

  # Disable serving static files from the `/public` folder by default since
  # Apache or NGINX already handles this.
  config.public_file_server.enabled = ENV['RAILS_SERVE_STATIC_FILES'].present?

  # Compress JavaScripts and CSS.
  config.assets.js_compressor = Uglifier.new(harmony: true)
  # config.assets.css_compressor = :sass

  # Do not fallback to assets pipeline if a precompiled asset is missed.
  config.assets.compile = false

  # `config.assets.precompile` and `config.assets.version` have moved to config/initializers/assets.rb

  # Enable serving of images, stylesheets, and JavaScripts from an asset server.
  # config.action_controller.asset_host = 'http://assets.example.com'

  # Specifies the header that your server uses for sending files.
  # config.action_dispatch.x_sendfile_header = 'X-Sendfile' # for Apache
  # config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect' # for NGINX

  # Store uploaded files on the local file system (see config/storage.yml for options)
  config.active_storage.service = :local

  # Mount Action Cable outside main process or domain
  # config.action_cable.mount_path = nil
  # config.action_cable.url = 'wss://example.com/cable'
  # config.action_cable.allowed_request_origins = [ 'http://example.com', /http:\/\/example.*/ ]

  # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
  # config.force_ssl = true

  # Use the lowest log level to ensure availability of diagnostic information
  # when problems arise.
  config.log_level = :debug

  # Prepend all log lines with the following tags.
  config.log_tags = [:request_id]

  # Use a different cache store in production.
  # config.cache_store = :mem_cache_store

  # Use a real queuing backend for Active Job (and separate queues per environment)
  # config.active_job.queue_adapter     = :resque
  # config.active_job.queue_name_prefix = "nurax-pg_#{Rails.env}"

  config.action_mailer.perform_caching = false

  # Ignore bad email addresses and do not raise email delivery errors.
  # Set this to true and configure the email server for immediate delivery to raise delivery errors.
  # config.action_mailer.raise_delivery_errors = false

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation cannot be found).
  config.i18n.fallbacks = true

  # Send deprecation notices to registered listeners.
  config.active_support.deprecation = :notify

  # Use default logging formatter so that PID and timestamp are not suppressed.
  config.log_formatter = ::Logger::Formatter.new

  # Use a different logger for distributed setups.
  # require 'syslog/logger'
  # config.logger = ActiveSupport::TaggedLogging.new(Syslog::Logger.new 'app-name')

  if ENV["RAILS_LOG_TO_STDOUT"].present?
    logger           = ActiveSupport::Logger.new(STDOUT)
    logger.formatter = config.log_formatter
    config.logger    = ActiveSupport::TaggedLogging.new(logger)
  end

  # Do not dump schema after migrations.
  config.active_record.dump_schema_after_migration = false

  require 'aws-sdk-secretsmanager'
  def fetch_secret
    aws_region = ENV['AWS_REGION'].presence || 'us-east-1'
    secret_name = ENV['SP_KEY_SECRET_NAME'].presence || 'production-sp-key'
    client = Aws::SecretsManager::Client.new(region: aws_region)
    begin
      get_secret_value_response = client.get_secret_value(secret_id: secret_name)
    rescue StandardError
      raise "AWS_REGION or SP_KEY_SECRET_NAME is not set"
    end
    get_secret_value_response.secret_string.gsub(/[{}"]/, '').gsub('\n', "\n")
  end

  # OmniAuth configuration settings
  config.sp_entity_id = ENV['SP_ENTITY'].presence || 'production-entity-id'
  config.idp_slo_target_url = ENV['IDP_SLO_TARGET_URL'].presence || 'https://login.emory.edu/idp/profile/SAML2/Redirect/SLO'
  config.assertion_consumer_service_url = ENV['ASSERTION_CS_URL'].presence || 'http://localhost:3000/users/auth/saml/callback'
  config.assertion_consumer_logout_service_url = ENV['ASSERTION_LOGOUT_URL'].presence || 'https://login.emory.edu/idp/profile/SAML2/Redirect/SLO'
  config.issuer = ENV['ISSUER'].presence || 'production-issuer'
  config.idp_sso_target_url = ENV['IDP_SSO_TARGET_URL'].presence || 'https://login.emory.edu/idp/profile/SAML2/Redirect/SSO'
  config.idp_cert = if ENV['IDP_CERT'].present? && File.exist?(ENV['IDP_CERT'])
                      File.read(ENV['IDP_CERT'])
                    else
                      'idp_cert'
                    end
  config.certificate = if ENV['SP_CERT'].present? && File.exist?(ENV['SP_CERT'])
                         File.read(ENV['SP_CERT'])
                       else
                         'sp_cert'
                       end
  config.private_key = ENV['IN_DOCKER'].present? ? 'dummy' : fetch_secret
  config.attribute_statements = {
    net_id: ["urn:oid:0.9.2342.19200300.100.1.1"],
    display_name: ["urn:oid:1.3.6.1.4.1.5923.1.1.1.2"],
    last_name: ["urn:oid:2.5.4.4"],
    title: ["urn:oid:2.5.4.12"],
    email: ["urn:oid:0.9.2342.19200300.100.1.3"],
    department: ["urn:oid:2.5.4.11"],
    status: ["urn:oid:0.9.2342.19200300.100.1.45"],
    ppid: ["urn:oid:2.5.4.5"],
    role: ["urn:oid:0.9.2342.19200300.100.1.45"]
  }
  config.uid_attribute = "urn:oid:2.5.4.5"
  config.security = {
    want_assertions_encrypted: true,
    want_assertions_signed: true,
    digest_method: XMLSecurity::Document::SHA1,
    signature_method: XMLSecurity::Document::RSA_SHA1
  }
end
