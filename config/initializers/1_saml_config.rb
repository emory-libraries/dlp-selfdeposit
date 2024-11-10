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
