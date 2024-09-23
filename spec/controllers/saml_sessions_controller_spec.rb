# frozen_string_literal: true
require 'rails_helper'

RSpec.describe SamlSessionsController, type: :controller do
  describe '#new' do
    before do
      @request.env["devise.mapping"] = Devise.mappings[:user]
    end

    context 'when redirect_to param is present' do
      it 'stores the redirect path' do
        get :new, params: { redirect_to: '/custom_path' }
        expect(controller.stored_location_for(:user)).to eq('/custom_path')
      end
    end

    context 'when referer is present' do
      it 'stores the referer path' do
        @request.env['HTTP_REFERER'] = '/referer_path'
        get :new
        expect(controller.stored_location_for(:user)).to eq('/referer_path')
      end
    end

    context 'when referer is the new user session url' do
      it 'does not store the referer path' do
        @request.env['HTTP_REFERER'] = new_user_session_url
        get :new
        expect(controller.stored_location_for(:user)).to be_nil
      end
    end
  end

  describe '#create' do
    let(:auth_hash) do
      OmniAuth::AuthHash.new(
        provider: 'saml',
        info: {
          mail: 'user@example.com',
          displayName: 'Test User',
          ou: 'Test Department',
          title: 'Test Title'
        }
      )
    end

    before do
      @request.env["devise.mapping"] = Devise.mappings[:user]
      @request.env["omniauth.auth"] = auth_hash
    end

    context 'when authentication is successful' do
      it 'signs in the user' do
        post :create
        expect(controller.current_user).not_to be_nil
      end

      it 'redirects to the dashboard' do
        post :create
        expect(response).to redirect_to(hyrax.dashboard_path)
      end

      it 'sets a success flash message' do
        post :create
        expect(flash[:notice]).to eq(I18n.t("devise.sessions.signed_in"))
      end
    end

    context 'when authentication fails' do
      before do
        allow(User).to receive(:from_saml).and_return(User.new)
      end

      it 'does not sign in the user' do
        post :create
        expect(controller.current_user).to be_nil
      end

      it 'redirects to the root path' do
        post :create
        expect(response).to redirect_to(root_path)
      end

      it 'sets an error flash message' do
        post :create
        expect(flash[:alert]).to eq(I18n.t("devise.failure.saml_invalid", reason: "Unable to create or update user account."))
      end
    end
  end

  describe '#after_sign_in_path_for' do
    let(:user) { create(:user) }

    it 'returns the omniauth origin if present' do
      @request.env['omniauth.origin'] = '/custom_path'
      expect(controller.after_sign_in_path_for(user)).to eq('/custom_path')
    end

    it 'returns the stored location if present' do
      controller.store_location_for(user, '/stored_path')
      expect(controller.after_sign_in_path_for(user)).to eq('/stored_path')
    end

    it 'returns the dashboard path if no other path is set' do
      expect(controller.after_sign_in_path_for(user)).to eq(hyrax.dashboard_path)
    end
  end

  describe '#after_sign_out_path_for' do
    it 'returns the root path' do
      expect(controller.after_sign_out_path_for(nil)).to eq(root_path)
    end
  end

  describe '#check_environment' do
    context 'when not in production environment' do
      before do
        allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new('development'))
      end

      it 'sets an alert flash message' do
        get :new
        expect(flash[:alert]).to eq("SAML authentication is only available in production.")
      end

      it 'redirects to the new user session path' do
        get :new
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context 'when in production environment' do
      before do
        allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new('production'))
      end

      it 'does not set an alert flash message' do
        get :new
        expect(flash[:alert]).to be_nil
      end

      it 'does not redirect to the new user session path' do
        get :new
        expect(response).not_to redirect_to(new_user_session_path)
      end
    end
  end
end
