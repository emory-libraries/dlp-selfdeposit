# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Hyrax::AdminSetCreateService, type: :service do
  describe 'find_or_create_default_admin_set' do
    context 'when the default admin set does not exist' do
      it 'creates and returns the default admin set' do
        admin_set = described_class.find_or_create_default_admin_set
        expect(admin_set.title).to eq described_class::DEFAULT_TITLE
      end
    end
  end

  describe 'default_admin_set?' do
    it 'returns true if the id is for the default admin set' do
      admin_set = described_class.find_or_create_default_admin_set
      expect(described_class.default_admin_set?(id: admin_set.id)).to eq true
    end

    it 'returns false if the id is not for the default admin set' do
      expect(described_class.default_admin_set?(id: Valkyrie::ID.new('123'))).to eq false
    end
  end
end
