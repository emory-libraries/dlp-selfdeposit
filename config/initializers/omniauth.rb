# frozen_string_literal: true

Rails.application.config.class.class_eval do
  attr_accessor :assertion_consumer_service_url,
                :assertion_consumer_logout_service_url,
                :issuer,
                :idp_sso_target_url,
                :idp_slo_target_url,
                :idp_cert,
                :certificate,
                :private_key,
                :attribute_statements,
                :uid_attribute,
                :security
end

Rails.application.config.assertion_consumer_service_url = nil
Rails.application.config.assertion_consumer_logout_service_url = nil
Rails.application.config.issuer = nil
Rails.application.config.idp_sso_target_url = nil
Rails.application.config.idp_slo_target_url = nil
Rails.application.config.idp_cert = nil
Rails.application.config.certificate = nil
Rails.application.config.private_key = nil
Rails.application.config.attribute_statements = {}
Rails.application.config.uid_attribute = nil
Rails.application.config.security = {}

Rails.application.config.middleware.use OmniAuth::Builder do
  if !Rails.env.development? && !Rails.env.test?
    provider :saml,
      assertion_consumer_service_url: Rails.application.config.assertion_consumer_service_url,
      assertion_consumer_logout_service_url: Rails.application.config.assertion_consumer_logout_service_url,
      issuer: Rails.application.config.issuer,
      idp_sso_target_url: Rails.application.config.idp_sso_target_url,
      idp_slo_target_url: Rails.application.config.idp_slo_target_url,
      idp_cert: Rails.application.config.idp_cert,
      certificate: Rails.application.config.certificate,
      private_key: Rails.application.config.private_key,
      attribute_statements: Rails.application.config.attribute_statements,
      uid_attribute: Rails.application.config.uid_attribute,
      security: Rails.application.config.security
  end
end

# Protect against forgery attacks
OmniAuth.config.allowed_request_methods = [:post]
