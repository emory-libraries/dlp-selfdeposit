# frozen_string_literal: true
require 'rails_helper'
require 'hyrax/specs/shared_specs/factories/administrative_sets'

RSpec.describe SelfDeposit::CustomQueries::FindFileSetCountsForAllPublications, :clean do
  subject(:query_handler) { described_class.new(query_service:) }
  let(:query_service)     { Hyrax.query_service }

  before { Hyrax.index_adapter.wipe! }

  describe '#find_file_set_counts_for_all_publications' do
    context 'when no objects match' do
      it 'returns an empty enum' do
        expect(query_handler.find_file_set_counts_for_all_publications).to be_a(Array)
        expect(query_handler.find_file_set_counts_for_all_publications.to_a).to be_empty
      end
    end

    context 'with objects that match' do
      let(:user) { FactoryBot.create(:user) }
      let(:admin_set) { FactoryBot.valkyrie_create(:hyrax_admin_set) }
      let(:file_set) { FactoryBot.valkyrie_create(:hyrax_file_set, :with_files, depositor: user.user_key, read_groups: ['public'], edit_users: [user]) }
      let(:publication) { FactoryBot.valkyrie_create(:publication, deduplication_key: '1234reet', admin_set_id: admin_set.id, depositor: user.user_key, members: [file_set]) }

      it 'returns an enum with one object' do
        publication

        expect(query_handler.find_file_set_counts_for_all_publications).to be_a(Array)
        expect(query_handler.find_file_set_counts_for_all_publications).to eq([['1234reet', 1]])
      end
    end
  end
end
