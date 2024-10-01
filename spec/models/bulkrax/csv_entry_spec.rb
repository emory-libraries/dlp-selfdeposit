# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Bulkrax::CsvEntry, type: :model do
  describe '#build_metadata with our added parsing logic' do
    let(:path) { File.expand_path('../../fixtures/csv/parsing_test.csv', __dir__) }
    let(:importer) do
      FactoryBot.build(
        :bulkrax_importer_csv,
        parser_fields: { "import_file_path" => path }
      )
    end
    let(:data) do
      { model: "Publication", title: "A Good Title", parent: "2", source_identifier: "1", publisher: nil, data_classification: nil, emory_content_type: nil }
    end
    subject(:entry) { described_class.new(importerexporter: importer, raw_metadata: data, identifier: data.fetch(:source_identifier)) }

    before { entry.build_metadata }

    it "passes in default values when fields are empty" do
      expect(entry.parsed_metadata['publisher']).to eq('Emory University Libraries')
      expect(entry.parsed_metadata['data_classification']).to eq('Public')
      expect(entry.parsed_metadata['emory_content_type']).to eq('http://id.loc.gov/vocabulary/resourceTypes/txt')
    end

    context 'when empty spaces are present in the values provided' do
      let(:data) do
        { model: "Publication",
          title: "A Good Title",
          parent: "2",
          source_identifier: "1",
          publisher: " Simon & Schuster ",
          data_classification: "Restricted ",
          emory_content_type: " Tactile" }
      end

      it 'strips out the spaces' do
        expect(entry.parsed_metadata['publisher']).to eq('Simon & Schuster')
        expect(entry.parsed_metadata['data_classification']).to eq('Restricted')
        expect(entry.parsed_metadata['emory_content_type']).to eq('http://id.loc.gov/vocabulary/resourceTypes/tac')
      end
    end

    context 'when trash values are passed into emory_content_type' do
      let(:data) do
        { model: "Publication",
          title: "A Good Title",
          parent: "2",
          source_identifier: "1",
          publisher: nil,
          data_classification: nil,
          emory_content_type: 'cartography' }
      end

      it 'returns the default text link' do
        expect(entry.parsed_metadata['emory_content_type']).to eq('http://id.loc.gov/vocabulary/resourceTypes/txt')
      end
    end
  end
end
