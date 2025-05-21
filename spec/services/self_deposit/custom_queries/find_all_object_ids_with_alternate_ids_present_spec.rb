# frozen_string_literal: true
require 'rails_helper'

RSpec.describe SelfDeposit::CustomQueries::FindAllObjectIdsWithAlternateIdsPresent, :clean do
  subject(:query_handler) { described_class.new(query_service:) }
  let(:query_service)     { Hyrax.query_service }

  before { Hyrax.index_adapter.wipe! }

  describe '#find_all_object_ids_with_alternate_ids_present' do
    context 'when no objects match' do
      it 'returns an empty enum' do
        expect(query_handler.find_all_object_ids_with_alternate_ids_present).to be_a(Array)
        expect(query_handler.find_all_object_ids_with_alternate_ids_present.to_a).to be_empty
      end
    end

    context 'with objects that match' do
      let(:publication) { FactoryBot.valkyrie_create(:publication, alternate_ids: [Valkyrie::ID.new('145djjdjd-emory')]) }

      it 'returns an enum with one object' do
        publication

        expect(query_handler.find_all_object_ids_with_alternate_ids_present).to be_a(Array)
        expect(query_handler.find_all_object_ids_with_alternate_ids_present.to_a.first).to eq(
          { "id" => publication.id, "alternate_ids_ssim" => ["145djjdjd-emory"] }
        )
      end
    end
  end
end
