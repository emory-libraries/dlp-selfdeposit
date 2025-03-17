# frozen_string_literal: true
require 'rails_helper'

RSpec.describe AuthConfig do
  describe '.use_database_auth?' do
    context 'when DATABASE_AUTH environment variable is set to "true"' do
      before do
        allow(ENV).to receive(:[]).with('DATABASE_AUTH').and_return('true')
      end

      it 'returns true' do
        expect(described_class.use_database_auth?).to be true
      end
    end

    context 'when DATABASE_AUTH environment variable is not "true"' do
      before do
        allow(ENV).to receive(:[]).with('DATABASE_AUTH').and_return(nil)
      end

      it 'returns false' do
        expect(described_class.use_database_auth?).to be false
      end

      it 'returns false for any other value' do
        allow(ENV).to receive(:[]).with('DATABASE_AUTH').and_return('false')
        expect(described_class.use_database_auth?).to be false

        allow(ENV).to receive(:[]).with('DATABASE_AUTH').and_return('1')
        expect(described_class.use_database_auth?).to be false

        allow(ENV).to receive(:[]).with('DATABASE_AUTH').and_return('')
        expect(described_class.use_database_auth?).to be false
      end
    end
  end
end
