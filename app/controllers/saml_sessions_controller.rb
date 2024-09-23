# frozen_string_literal: true
class SamlSessionsController < Devise::SamlSessionsController
  before_action :store_redirect_path, only: [:new]
  before_action :check_environment

  def new
    if params[:redirect_to].present?
      store_location_for(:user, params[:redirect_to])
    elsif request.referer.present? && request.referer != new_user_session_url
      store_location_for(:user, request.referer)
    end
    super
  end

  def create
    super do |user|
      if user.persisted?
        flash[:notice] = I18n.t("devise.sessions.signed_in")
        redirect_to after_sign_in_path_for(user) and return
      else
        flash[:alert] = I18n.t("devise.failure.saml_invalid", reason: "Unable to create or update user account.")
        redirect_to root_path and return
      end
    end
  end

  def after_sign_in_path_for(resource)
    stored_location_for(resource) || hyrax.dashboard_path
  end

  def after_sign_out_path_for(_resource_or_scope)
    root_path
  end

  protected

  def store_redirect_path
    store_location_for(:user, params[:redirect_to]) if params[:redirect_to]
  end

  def stored_redirect_path_or_default
    stored_location_for(:user) || hyrax.dashboard_path
  end

  def check_environment
    return if Rails.env.production?
    flash[:alert] = "SAML authentication is only available in production."
    redirect_to new_user_session_path
  end
end
