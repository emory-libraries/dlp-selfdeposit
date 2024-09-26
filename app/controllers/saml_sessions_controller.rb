# frozen_string_literal: true
class SamlSessionsController < Devise::SamlSessionsController
  before_action :store_redirect_path, only: [:new]
  before_action :check_environment

  def new
    super
  end

  def create
    authenticate_resource
    handle_authenticated_resource
  rescue StandardError => e
    handle_authentication_error(e)
  end

  def after_sign_in_path_for(resource)
    stored_location_for(resource) || root_path
  end

  def after_sign_out_path_for(_resource_or_scope)
    root_path
  end

  private

  def authenticate_resource
    self.resource = warden.authenticate!(auth_options)
  end

  def handle_authenticated_resource
    if resource&.persisted?
      sign_in_resource
    else
      handle_invalid_resource
    end
  end

  def sign_in_resource
    set_flash_message!(:notice, :signed_in)
    sign_in(resource_name, resource)
    yield resource if block_given?
    respond_with resource, location: after_sign_in_path_for(resource)
  end

  def handle_invalid_resource
    error_flash_and_redirect("Unable to create or update user account.")
  end

  def handle_authentication_error(error)
    Rails.logger.error("SAML authentication error: #{error.message}")
    error_flash_and_redirect("Unable to create or update user account.")
  end

  def error_flash_and_redirect(reason)
    flash[:alert] = I18n.t("devise.failure.saml_invalid", reason:)
    redirect_to root_path
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
