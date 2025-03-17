# frozen_string_literal: true
# require 'rails_helper'

# RSpec.describe OmniauthController, type: :controller do
#   # Set the controller to use Devise's layout
#   routes { Devise::Engine.routes }

#   describe '#new' do
#     before do
#       @request.env['devise.mapping'] = Devise.mappings[:user]
#       @request.env['warden'] = double(Warden::Proxy)
#       allow(@request.env['warden']).to receive(:authenticate?).and_return(false)
#       allow(@request.env['warden']).to receive(:authenticate!).and_return(false)
#     end

#     context 'when not in production environment' do
#       before do
#         allow(Rails.env).to receive(:production?).and_return(false)
#       end

#       it 'calls the superclass implementation' do
#         expect_any_instance_of(Devise::SessionsController).to receive(:new)
#         get :new
#       end
#     end

#     context 'when in production environment' do
#       before do
#         allow(Rails.env).to receive(:production?).and_return(true)
#       end

#       it 'redirects to saml login' do
#         get :new
#         expect(response).to redirect_to('/auth/saml')
#       end
#     end
#   end

#   describe 'routing' do
#     it 'routes POST /auth/saml/callback to omniauth_callbacks#saml' do
#       expect(post: '/auth/saml/callback').to route_to(
#         controller: 'omniauth_callbacks',
#         action: 'saml'
#       )
#     end

#     it 'routes POST /auth/saml to omniauth_callbacks#passthru' do
#       expect(post: '/auth/saml').to route_to(
#         controller: 'omniauth_callbacks',
#         action: 'passthru'
#       )
#     end

#     it 'routes GET /auth/failure to users/omniauth_callbacks#failure' do
#       expect(get: '/auth/failure').to route_to(
#         controller: 'users/omniauth_callbacks',
#         action: 'failure'
#       )
#     end

#     it 'routes GET /sign_out to devise/sessions#destroy' do
#       expect(get: '/sign_out').to route_to(
#         controller: 'devise/sessions',
#         action: 'destroy'
#       )
#     end
#   end
# end
