# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Users::OmniauthCallbacksController do
  include Rails.application.routes.url_helpers

  def dashboard_path
    '/dashboard?locale=en'
  end

  def root_path
    '/?locale=en'
  end

  before do
    @request.env["devise.mapping"] = Devise.mappings[:user]
    @request.env['warden'] = double(Warden::Proxy)
    allow(@request.env['warden']).to receive(:authenticate!).and_return(true)
    allow(@request.env['warden']).to receive(:authenticate?).and_return(false)
    allow(@request.env['warden']).to receive(:user).and_return(user)
    allow(@request.env['warden']).to receive(:set_user)
    allow(controller).to receive(:current_user).and_return(user)
  end

  describe '#saml' do
    let(:auth_hash) do
      OmniAuth::AuthHash.new(
        provider: 'saml',
        uid: '12345',
        info: {
          net_id: 'test123',
          display_name: 'Test User',
          email: 'test123@emory.edu'
        }
      )
    end

    before do
      @request.env["omniauth.auth"] = auth_hash
    end

    context 'when user exists and is authorized' do
      let(:user) { create(:user) }

      before do
        allow(User).to receive(:from_omniauth).and_return(user)
        @request.env["omniauth.origin"] = '/custom/path'
      end

      it 'signs in and redirects the user' do
        get :saml
        expect(response).to redirect_to('/custom/path')
        expect(flash[:notice]).to match(/Successfully authenticated from SAML account./)
      end

      context 'when omniauth.origin is not present' do
        before do
          @request.env["omniauth.origin"] = nil
        end

        it 'redirects to the dashboard' do
          get :saml
          expect(response).to redirect_to(dashboard_path)
        end
      end
    end

    context 'when user is not authorized' do
      let(:unauthorized_user) { User.new }
      let(:user) { unauthorized_user }

      before do
        allow(User).to receive(:from_omniauth).and_return(unauthorized_user)
      end

      it 'redirects to root with error message' do
        get :saml
        expect(response).to redirect_to(root_path)
        expect(flash[:notice]).to eq(
          'Could not authenticate you from SAML because "you aren\'t authorized to use this application.".'
        )
      end
    end
  end

  describe '#failure' do
    let(:user) { nil }

    it 'redirects to root path' do
      get :failure
      expect(response).to redirect_to(root_path)
    end
  end
end