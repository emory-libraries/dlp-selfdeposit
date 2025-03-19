# frozen_string_literal: true
Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports.
  config.consider_all_requests_local = true

  # Enable/disable caching. By default caching is disabled.
  # Run rails dev:cache to toggle caching.
  if Rails.root.join('tmp', 'caching-dev.txt').exist?
    config.action_controller.perform_caching = true

    config.cache_store =
      ENV['MEMCACHED_HOST'] ? [:mem_cache_store, ENV['MEMCACHED_HOST']] : :memory_store

    config.public_file_server.headers = {
      'Cache-Control' => "public, max-age=#{2.days.to_i}"
    }
  else
    config.action_controller.perform_caching = false

    config.cache_store = :null_store
  end

  # Store uploaded files on the local file system (see config/storage.yml for options)
  config.active_storage.service = :local

  # Don't care if the mailer can't send.
  config.action_mailer.raise_delivery_errors = false

  config.action_mailer.perform_caching = false

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = :page_load

  # Highlight code that triggered database queries in logs.
  config.active_record.verbose_query_logs = true

  # Debug mode disables concatenation and preprocessing of assets.
  # This option may cause significant delays in view rendering with a large
  # number of complex assets.
  config.assets.debug = true

  # Suppress logger output for asset requests.
  config.assets.quiet = true

  # Raises error for missing translations
  # config.action_view.raise_on_missing_translations = true

  # Use an evented file watcher to asynchronously detect changes in source code,
  # routes, locales, etc. This feature depends on the listen gem.
  config.file_watcher = ActiveSupport::EventedFileUpdateChecker

  # Allowlist container IP for web-console
  # FIXME: Update next line to use `allowed_ips` once web-console is upgraded to 4.0.3+
  config.web_console.whitelisted_ips = Socket.getifaddrs.select do |ifa|
    ifa&.addr&.ipv4_private?
  end.map do |ifa|
    IPAddr.new(ifa.addr.ip_address + '/' + ifa.netmask.ip_address)
  end

  config.sp_entity_id = ENV['SP_ENTITY'].presence || 'test-entity-id'
  config.idp_slo_target_url = ENV['IDP_SLO_TARGET_URL'].presence || 'https://login.emory.edu/idp/profile/SAML2/Redirect/SLO'
  config.assertion_consumer_service_url = ENV['ASSERTION_CS_URL'].presence || 'http://localhost:3000/users/auth/saml/callback'
  config.assertion_consumer_logout_service_url = ENV['ASSERTION_LOGOUT_URL'].presence || 'https://login.emory.edu/idp/profile/SAML2/Redirect/SLO'
  config.issuer = ENV['ISSUER'].presence || 'test-issuer'
  config.idp_sso_target_url = ENV['IDP_SSO_TARGET_URL'].presence || 'https://login.emory.edu/idp/profile/SAML2/Redirect/SSO'
  config.idp_cert = ENV['IDP_CERT'].presence || 'test-cert'
  config.certificate = ENV['SP_CERT'].presence || 'test-certificate'
  config.private_key = ENV['SP_KEY'].presence || 'test-private-key'
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
