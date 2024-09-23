# frozen_string_literal: true
require 'rails_helper'

RSpec.describe User, type: :model do
  describe '.from_saml' do
    let(:auth_hash) do
      OpenStruct.new(
        uid: '12345',
        info: OpenStruct.new(
          mail: 'user@example.com',
          displayName: 'Test User',
          ou: 'Test Department',
          title: 'Test Title'
        )
      )
    end

    context 'when in production environment' do
      before do
        allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new('production'))
      end

      context 'when user does not exist' do
        it 'creates a new user' do
          expect { User.from_saml(auth_hash) }.to change(User, :count).by(1)
        end

        it 'sets the correct attributes' do
          user = User.from_saml(auth_hash)
          expect(user.email).to eq('user@example.com')
          expect(user.display_name).to eq('Test User')
          expect(user.department).to eq('Test Department')
          expect(user.title).to eq('Test Title')
          expect(user.uid).to eq('12345')
        end
      end

      context 'when user already exists' do
        let!(:existing_user) { User.create(email: 'user@example.com', password: 'password') }

        it 'does not create a new user' do
          expect { User.from_saml(auth_hash) }.not_to change(User, :count)
        end

        it 'updates the existing user' do
          user = User.from_saml(auth_hash)
          expect(user.id).to eq(existing_user.id)
          expect(user.display_name).to eq('Test User')
          expect(user.department).to eq('Test Department')
          expect(user.title).to eq('Test Title')
          expect(user.uid).to eq('12345')
        end
      end

      context 'when SAML response is invalid' do
        let(:invalid_auth_hash) do
          OpenStruct.new(
            uid: '12345',
            info: OpenStruct.new(
              mail: nil,
              displayName: 'Test User',
              ou: 'Test Department',
              title: 'Test Title'
            )
          )
        end

        it 'logs an error' do
          expect(Rails.logger).to receive(:error).with(/Nil user detected/)
          User.from_saml(invalid_auth_hash)
        end

        it 'returns a new, unsaved user' do
          user = User.from_saml(invalid_auth_hash)
          expect(user).to be_a(User)
          expect(user).not_to be_persisted
        end
      end
    end

    context 'when not in production environment' do
      before do
        allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new('development'))
      end

      it 'does not create or update a user' do
        expect(User.from_saml(auth_hash)).to be_nil
      end
    end
  end

  describe '.log_saml_error' do
    let(:auth_hash) do
      OpenStruct.new(
        info: OpenStruct.new(
          mail: nil,
          displayName: 'Test User',
          ou: 'Test Department',
          title: 'Test Title'
        )
      )
    end

    it 'logs an error when email is missing' do
      expect(Rails.logger).to receive(:error).with(/Nil user detected: SAML didn't pass an email/)
      User.log_saml_error(auth_hash)
    end

    it 'logs an error when user creation or update fails' do
      auth_hash.info.mail = 'user@example.com'
      expect(Rails.logger).to receive(:error).with(/Failed to create\/update user/)
      User.log_saml_error(auth_hash)
    end
  end
end
