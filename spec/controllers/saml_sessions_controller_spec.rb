# frozen_string_literal: true
require 'rails_helper'

RSpec.describe SamlSessionsController, type: :controller do
  include Devise::Test::ControllerHelpers

  let(:warden) { double(Warden::Proxy) }
  let(:user) { instance_double(User, persisted?: true) }

  before do
    @request.env["devise.mapping"] = Devise.mappings[:user]
    @request.env['warden'] = warden
    allow(warden).to receive(:authenticate?).and_return(false)
    allow(warden).to receive(:set_user)
    allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new("production"))
  end

  describe "GET #new" do
    before do
      allow_any_instance_of(OneLogin::RubySaml::Authrequest).to receive(:create).and_return("http://idp.example.com/saml/auth")
    end

    it "stores the redirect_to parameter" do
      get :new, params: { redirect_to: '/dashboard' }
      expect(session['user_return_to']).to eq('/dashboard')
    end

    it "stores the referer if no redirect_to parameter" do
      request.env['HTTP_REFERER'] = '/previous_page'
      get :new
      expect(session['user_return_to']).to eq('/previous_page')
    end

    it "doesn't store referer if it matches new_user_session_url" do
      request.env['HTTP_REFERER'] = new_saml_user_session_url
      get :new
      expect(session['user_return_to']).to be_nil
    end

    it "initiates SAML authentication" do
      get :new
      expect(response).to redirect_to("http://idp.example.com/saml/auth")
    end
  end

  describe "POST #create" do
    context "in production environment" do
      before do
        allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new("production"))
      end

      it "sets a success notice and redirects to after_sign_in_path when authentication is successful" do
        allow(warden).to receive(:authenticate!).and_return(user)
        allow(warden).to receive(:user).with(:user).and_return(user)
        allow(controller).to receive(:after_sign_in_path_for).with(user).and_return('/dashboard')
        post :create
        expect(flash[:notice]).to eq(I18n.t("devise.sessions.signed_in"))
        expect(response).to redirect_to('/dashboard')
      end

      it "sets an alert and redirects to root_path when authentication fails" do
        allow(warden).to receive(:authenticate!).and_return(nil)
        allow(warden).to receive(:user).with(:user).and_return(nil)
        post :create
        expect(flash[:alert]).to eq(I18n.t("devise.failure.saml_invalid", reason: "Unable to create or update user account."))
        expect(response).to redirect_to(root_path)
      end
    end

    context "in non-production environment" do
      before do
        allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new("development"))
      end

      it "redirects to sign in path with an alert" do
        post :create
        expect(response).to redirect_to(new_user_session_path)
        expect(flash[:alert]).to eq("SAML authentication is only available in production.")
      end
    end
  end

  describe "#after_sign_in_path_for" do
    let(:user) { instance_double(User) }

    it "returns stored location if available" do
      allow(controller).to receive(:stored_location_for).with(user).and_return('/stored_path')
      expect(controller.after_sign_in_path_for(user)).to eq('/stored_path')
    end

    it "returns root path if no stored location" do
      allow(controller).to receive(:stored_location_for).with(user).and_return(nil)
      expect(controller.after_sign_in_path_for(user)).to eq(root_path)
    end
  end

  describe "#check_environment" do
    context "in production" do
      before { allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new("production")) }

      it "allows access" do
        get :new
        expect(response).not_to redirect_to(new_user_session_path)
      end
    end

    context "in non-production" do
      before { allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new("development")) }

      it "redirects to sign in path with an alert" do
        get :new
        expect(response).to redirect_to(new_user_session_path)
        expect(flash[:alert]).to eq("SAML authentication is only available in production.")
      end
    end
  end
end

