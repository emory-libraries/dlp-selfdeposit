# frozen_string_literal: true
Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.
  config.assets.debug = true

  # The test environment is used exclusively to run your application's
  # test suite. You never need to work with it otherwise. Remember that
  # your test database is "scratch space" for the test suite and is wiped
  # and recreated between test runs. Don't rely on the data there!
  config.cache_classes = true

  # Do not eager load code on boot. This avoids loading your whole application
  # just for the purpose of running a single test. If you are using a tool that
  # preloads Rails for running tests, you may have to set it to true.
  config.eager_load = false

  # Configure public file server for tests with Cache-Control for performance.
  config.public_file_server.enabled = true
  config.public_file_server.headers = {
    'Cache-Control' => "public, max-age=#{1.hour.to_i}"
  }

  # Show full error reports and disable caching.
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Raise exceptions instead of rendering exception templates.
  config.action_dispatch.show_exceptions = false

  # Disable request forgery protection in test environment.
  config.action_controller.allow_forgery_protection = false

  # Store uploaded files on the local file system in a temporary directory
  config.active_storage.service = :test

  config.action_mailer.perform_caching = false

  # Tell Action Mailer not to deliver emails to the real world.
  # The :test delivery method accumulates sent emails in the
  # ActionMailer::Base.deliveries array.
  config.action_mailer.delivery_method = :test

  # Print deprecation notices to the stderr.
  config.active_support.deprecation = :stderr

  # Raises error for missing translations
  # config.action_view.raise_on_missing_translations = true
  # OmniAuth configuration settings
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
