# frozen_string_literal: true
class ApplicationController < ActionController::Base
  helper Openseadragon::OpenseadragonHelper
  # Adds a few additional behaviors into the application controller
  include Blacklight::Controller
  include Hydra::Controller::ControllerBehavior

  # Adds Hyrax behaviors into the application controller
  include Hyrax::Controller
  include Hyrax::ThemedLayoutController
  with_themed_layout '1_column'

  protect_from_forgery with: :exception

  def saml_redirect
    respond_to { |wants| wants.html { render 'shared/saml_redirect' } }
  end

  private

  # Hyrax v5.0.1 override: changes html redirect to our saml path
  def deny_access_for_anonymous_user(exception, json_message)
    session['user_return_to'] = request.url
    respond_to do |wants|
      wants.html do
        if AuthConfig.use_database_auth?
          redirect_to main_app.new_user_session_path, alert: exception.message
        else
          redirect_to main_app.saml_redirect_path(origin: request.url), alert: exception.message
        end
      end
      wants.json { render_json_response(response_type: :unauthorized, message: json_message) }
    end
  end
end
