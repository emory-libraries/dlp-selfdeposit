# frozen_string_literal: true

class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  skip_before_action :verify_authenticity_token, only: [:saml, :failure]

  def saml
    @user = User.from_omniauth(request.env["omniauth.auth"])

    if @user.persisted?
      sign_in @user
      redirect_to request.env["omniauth.origin"] || request.referer || root_path
      set_flash_message(:notice, :success, kind: "SAML")
    else
      redirect_to root_path
      set_flash_message(:notice, :failure, kind: "SAML", reason: "you aren't authorized to use this application.")
    end
  end

  def failure
    redirect_to root_path
    set_flash_message(:notice, :failure, kind: "SAML", reason: "saml response is invalid")
  end
end
