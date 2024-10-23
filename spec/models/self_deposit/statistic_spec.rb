# frozen_string_literal: true
require 'rails_helper'

RSpec.describe SelfDeposit::Statistic, :clean, type: :model do
  let(:publication) do
    Publication.new(
      id: '123qyz',
      data_classification: 'Public',
      content_genre: 'Manuscript',
      holding_repository: 'Emory Libraries',
      creator: 'Dr. Seuss',
      rights_statement: 'http://rightsstatements.org/vocab/NoC-NC/1.0/',
      deduplication_key: 'abc123',
      title: 'Publication 1'
    )
  end
  let(:publication2) do
    Publication.new(
      id: '123abcab',
      data_classification: 'Public',
      content_genre: 'Article',
      holding_repository: 'Emory Libraries',
      creator: 'Dr. Seuss',
      rights_statement: 'http://rightsstatements.org/vocab/NoC-NC/1.0/',
      deduplication_key: 'def456',
      title: 'Publication 2'
    )
  end

  before { [publication, publication2].each { |p| Hyrax.index_adapter.save(resource: p) } }
  after { Hyrax.index_adapter.wipe! }

  describe '.content_genres' do
    it 'pulls content_genres with their counts' do
      expect(described_class.content_genres).to eq({ "Manuscript" => 1, "Article" => 1 })
    end

    it 'calls Hyrax::Statistic.query_works' do
      allow(::Hyrax::Statistic).to receive(:query_works).and_call_original

      expect(::Hyrax::Statistic).to receive(:query_works)
      described_class.content_genres
    end

    context 'with a blank value in content_genre' do
      let(:publication) do
        Publication.new(
          id: '123qyz',
          data_classification: 'Public',
          content_genre: '',
          holding_repository: 'Emory Libraries',
          creator: 'Dr. Seuss',
          rights_statement: 'http://rightsstatements.org/vocab/NoC-NC/1.0/',
          deduplication_key: 'abc123',
          title: 'Publication 1'
        )
      end

      it 'pulls content_genres with that contains Unknown' do
        expect(described_class.content_genres).to eq({ "Unknown" => 1, "Article" => 1 })
      end
    end
  end
end
