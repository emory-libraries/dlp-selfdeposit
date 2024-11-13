# frozen_string_literal: true
require 'rails_helper'

RSpec.describe User, type: :model do
  describe '.from_omniauth' do
    let(:auth_hash) do
      OpenStruct.new(
        provider: 'saml',
        uid: '12345',
        info: OpenStruct.new(
          net_id: 'testuser',
          display_name: 'Test User'
        )
      )
    end

    context 'when user exists' do
      let!(:existing_user) { create(:emory_saml_user, uid: 'testuser') }

      it 'updates the user attributes' do
        user = User.from_omniauth(auth_hash)
        expect(user.display_name).to eq('Test User')
        expect(user.ppid).to eq('12345')
        expect(user.email).to eq('testuser@emory.edu')
      end

      it 'does not create a new user' do
        expect { User.from_omniauth(auth_hash) }.not_to change(User, :count)
      end
    end

    context 'when net_id is tezprox' do
      let(:tezprox_auth) do
        OpenStruct.new(
          provider: 'saml',
          uid: '12345',
          info: OpenStruct.new(
            net_id: 'tezprox',
            display_name: 'Test User'
          )
        )
      end

      let!(:existing_user) { create(:emory_saml_user, :tezprox) }

      it 'updates other attributes' do
        user = User.from_omniauth(tezprox_auth)
        expect(user.display_name).to eq('Test User')
        expect(user.ppid).to eq('12345')
      end

      it 'does not set the email' do
        original_email = existing_user.email
        user = User.from_omniauth(tezprox_auth)
        expect(user.email).to eq(original_email)
      end
    end

    context 'when SAML response is invalid' do
      let(:invalid_auth_hash) do
        OpenStruct.new(
          provider: 'saml',
          uid: '12345',
          info: OpenStruct.new(
            net_id: nil,
            display_name: 'Test User'
          )
        )
      end

      it 'logs an error' do
        expect(Rails.logger).to receive(:error).with(/Nil user detected/)
        User.from_omniauth(invalid_auth_hash)
      end

      it 'returns a new unsaved user' do
        user = User.from_omniauth(invalid_auth_hash)
        expect(user).to be_a(User)
        expect(user).not_to be_persisted
      end
    end
  end

  describe '.log_omniauth_error' do
    let(:auth_hash) do
      OpenStruct.new(
        provider: 'saml',
        info: OpenStruct.new(
          net_id: nil,
          display_name: 'Test User'
        )
      )
    end

    it 'logs an error when net_id is missing' do
      expect(Rails.logger).to receive(:error).with(/Nil user detected: SAML didn't pass a net_id/)
      User.log_omniauth_error(auth_hash)
    end

    it 'logs an unauthorized login attempt when net_id is present' do
      auth_hash.info.net_id = 'testuser'
      expect(Rails.logger).to receive(:error).with(/Unauthorized user attempted login/)
      User.log_omniauth_error(auth_hash)
    end
  end

  describe '.assign_user_attributes' do
    let(:user) { create(:emory_saml_user) }
    let(:auth_hash) do
      OpenStruct.new(
        provider: 'saml',
        uid: '12345',
        info: OpenStruct.new(
          net_id: 'testuser',
          display_name: 'Test User'
        )
      )
    end

    it 'assigns the correct attributes' do
      User.assign_user_attributes(user, auth_hash)
      expect(user.display_name).to eq('Test User')
      expect(user.ppid).to eq('12345')
      expect(user.email).to eq('testuser@emory.edu')
    end

    context 'when net_id is tezprox' do
      let(:tezprox_auth) do
        OpenStruct.new(
          provider: 'saml',
          uid: '12345',
          info: OpenStruct.new(
            net_id: 'tezprox',
            display_name: 'Test User'
          )
        )
      end

      it 'does not update email' do
        original_email = user.email
        User.assign_user_attributes(user, tezprox_auth)
        expect(user.email).to eq(original_email)
      end

      it 'updates other attributes' do
        User.assign_user_attributes(user, tezprox_auth)
        expect(user.display_name).to eq('Test User')
        expect(user.ppid).to eq('12345')
      end
    end
  end
end
