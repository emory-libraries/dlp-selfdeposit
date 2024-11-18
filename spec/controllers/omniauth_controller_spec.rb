# frozen_string_literal: true
require 'rails_helper'

RSpec.describe OmniauthController do
  describe '#new' do
    before do
      @request.env['devise.mapping'] = Devise.mappings[:user]
      @request.env['warden'] = double(Warden::Proxy)
      allow(@request.env['warden']).to receive(:authenticate?).and_return(false)
      allow(@request.env['warden']).to receive(:authenticate!).and_return(false)
    end

    context 'when in production environment' do
      before do
        allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new('production'))
      end

      it 'redirects to shibboleth login' do
        get :new
        expect(response).to redirect_to(user_saml_omniauth_authorize_path)
      end
    end

    context 'when not in production environment' do
      before do
        allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new('development'))
      end

      it 'renders the default devise login page' do
        get :new
        expect(response).to be_successful
        expect(response).to render_template('devise/sessions/new')
      end
    end
  end

  describe 'routing' do
    it 'routes GET /sign_in to omniauth#new' do
      expect(get: '/sign_in').to route_to(
        controller: 'omniauth',
        action: 'new'
      )
    end

    it 'routes POST /sign_in to users/omniauth_callbacks#saml' do
      expect(post: '/sign_in').to route_to(
        controller: 'users/omniauth_callbacks',
        action: 'saml'
      )
    end

    it 'routes GET /sign_out to devise/sessions#destroy' do
      expect(get: '/sign_out').to route_to(
        controller: 'devise/sessions',
        action: 'destroy'
      )
    end
  end
end
