# frozen_string_literal: true
require 'rails_helper'
require 'hyrax/transactions'

RSpec.describe Hyrax::Transactions::Steps::SetNoidId do
  subject(:step) { described_class.new }
  let(:publication) { FactoryBot.valkyrie_create(:publication) }

  describe '#call' do
    context 'without a passed ID' do
      it 'is a success' do
        expect(step.call(publication)).to be_success
        expect(publication.emory_persistent_id).to be_present
      end
    end

    context 'with a passed ID' do
      let(:fake_id) { '123jkdcjh-emory' }
      it 'is a success' do
        expect(step.call(publication, emory_persistent_id: fake_id)).to be_success
        expect(publication.emory_persistent_id).to eq(fake_id)
      end
    end
  end
end
