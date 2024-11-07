class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def saml
    @user = User.from_omniauth(request.env["omniauth.auth"])

    if @user.persisted?
      sign_in @user
     redirect_to request.env["omniauth.origin"] || hyrax.dashboard_path
      set_flash_message(:notice, :success, kind: "SAML")
    else
      redirect_to root_path
      set_flash_message(:notice, :failure, kind: "SAML", reason: "you aren't authorized to use this application.")
    end
  end

  def failure
    redirect_to root_path
  end
end 