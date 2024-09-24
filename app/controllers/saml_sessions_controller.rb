# frozen_string_literal: true
class SamlSessionsController < Devise::SamlSessionsController
  before_action :store_redirect_path, only: [:new]
  before_action :check_environment

  def new
    super
  end

  def create
    self.resource = warden.authenticate!(auth_options)
    if resource&.persisted?
      set_flash_message!(:notice, :signed_in)
      sign_in(resource_name, resource)
      yield resource if block_given?
      respond_with resource, location: after_sign_in_path_for(resource)
    else
      flash[:alert] = I18n.t("devise.failure.saml_invalid", reason: "Unable to create or update user account.")
      redirect_to root_path
    end
  rescue StandardError => e
    Rails.logger.error("SAML authentication error: #{e.message}")
    flash[:alert] = I18n.t("devise.failure.saml_invalid", reason: "Unable to create or update user account.")
    redirect_to root_path
  end

  def after_sign_in_path_for(resource)
    stored_location_for(resource) || root_path
  end

  def after_sign_out_path_for(_resource_or_scope)
    root_path
  end

  protected

  def store_redirect_path
    if params[:redirect_to].present?
      store_location_for(:user, params[:redirect_to])
    elsif request.referer.present? && request.referer != new_saml_user_session_url
      store_location_for(:user, request.referer)
    end
  end

  def stored_redirect_path_or_default
    stored_location_for(:user) || root_path
  end

  def check_environment
    return if Rails.env.production?
    flash[:alert] = "SAML authentication is only available in production."
    redirect_to new_user_session_path
  end
end
