# frozen_string_literal: true
require 'rails_helper'

RSpec.describe ::SolrDocument, type: :model do
  subject(:document) { described_class.new(attributes) }
  let(:attributes) { {} }
  multiple_valued_fields = described_class::METHOD_ASSIGNMENTS.select { |_k, v| v.last == 'm' }
  single_valued_fields = described_class::METHOD_ASSIGNMENTS.dup - multiple_valued_fields

  shared_examples('tests for a direct solr index value return') do |method_name, solr_field, val|
    describe "##{method_name}" do
      let(:attributes) { { "#{solr_field}": [val] } }

      it 'returns the value from the solr document index' do
        expect(document.send(method_name)).to eq attributes[solr_field.to_sym]
      end
    end
  end

  multiple_valued_fields.each do |method_name, solr_field|
    include_examples('tests for a direct solr index value return', method_name, solr_field, ["test string", "another string", "last string"])
  end

  single_valued_fields.each do |method_name, solr_field|
    include_examples('tests for a direct solr index value return', method_name, solr_field, "test string")
  end

  include_examples('tests for a direct solr index value return',
                   'system_of_record_ID',
                   'system_of_record_ID_ssi',
                   '12345678-cor')

  context '#export_as_ris' do
    def ris_right_test(right_fields:, expected_ty_field:)
      right_fields.each { |expected_field| expect(document.export_as_ris('https://example.com')).to include("#{expected_field}  -") }
      expect(document.export_as_ris('https://example.com')).to include("TY  - #{expected_ty_field}")
      expect(document.export_as_ris('https://example.com')).to include("L2  - https://example.com/purl/12345678-cor")
    end

    def ris_wrong_test(wrong_fields:)
      wrong_fields.each { |expected_field| expect(document.export_as_ris('https://example.com')).not_to include("#{expected_field}  -") }
    end

    let(:attributes) do
      { 'content_genre_ssi': 'Article',
        'title_tesim': ['A Good Title'],
        'creator_tesim': ['Mark Twain, Missouri'],
        'language_tesim': ['English'],
        'date_issued_year_tesi': '1910',
        'publisher_tesim': ['Simon & Schuster'],
        'final_published_versions_tesim': ['http://dx.doi.org/10.1186/1742-4690-9-S2-P36'],
        'parent_title_tesi': 'Parent Title',
        'conference_name_tesi': 'Samvera 2025',
        'volume_tesi': '10',
        'issue_tesi': '15',
        'page_range_start_tesi': '100',
        'page_range_end_tesi': '200',
        'place_of_production_tesi': 'Boston, Massachusetts, USA',
        'emory_persistent_id_ssi': '12345678-cor' }
    end

    describe 'with a genre of Article' do
      it('contains the right fields') { ris_right_test(right_fields: ['TY', 'TI', 'AU', 'LA', 'PY', 'PB', 'DO', 'JO', 'VL', 'IS', 'SP', 'EP', 'CY', 'L2'], expected_ty_field: 'JOUR') }
      it('does not contain the wrong fields') { ris_wrong_test(wrong_fields: ['T2', 'BT']) }

      context 'empty fields' do
        subject(:document) { described_class.new(attributes.merge('publisher_tesim': "", 'parent_title_tesi': "")) }

        it('does not contain empty fields') { ris_wrong_test(wrong_fields: ['PB', 'JO']) }
      end
    end

    describe 'with a genre of Book' do
      subject(:document) { described_class.new(attributes.merge('content_genre_ssi': 'Book')) }

      it('contains the right fields') { ris_right_test(right_fields: ['TY', 'TI', 'AU', 'LA', 'PY', 'PB', 'DO', 'CY', 'L2'], expected_ty_field: 'BOOK') }
      it('does not contain the wrong fields') { ris_wrong_test(wrong_fields: ['BT', 'JO', 'T2', 'VL', 'IS', 'SP', 'EP']) }

      context 'empty fields' do
        subject(:document) { described_class.new(attributes.merge('content_genre_ssi': 'Book', 'publisher_tesim': "", 'final_published_versions_tesim': "")) }

        it('does not contain empty fields') { ris_wrong_test(wrong_fields: ['PB', 'DO']) }
      end
    end

    describe 'with a genre of Book Chapter' do
      subject(:document) { described_class.new(attributes.merge('content_genre_ssi': 'Book Chapter')) }

      it('contains the right fields') { ris_right_test(right_fields: ['TY', 'TI', 'AU', 'LA', 'PY', 'PB', 'DO', 'BT', 'SP', 'EP', 'CY', 'L2'], expected_ty_field: 'CHAP') }
      it('does not contain the wrong fields') { ris_wrong_test(wrong_fields: ['JO', 'T2', 'VL', 'IS']) }

      context 'empty fields' do
        subject(:document) { described_class.new(attributes.merge('content_genre_ssi': 'Book Chapter', 'publisher_tesim': "", 'final_published_versions_tesim': "")) }

        it('does not contain empty fields') { ris_wrong_test(wrong_fields: ['PB', 'DO']) }
      end
    end

    describe 'with a genre of Conference Paper' do
      subject(:document) { described_class.new(attributes.merge('content_genre_ssi': 'Conference Paper')) }

      it('contains the right fields') { ris_right_test(right_fields: ['TY', 'TI', 'AU', 'LA', 'PY', 'PB', 'DO', 'T2', 'VL', 'IS', 'CY', 'L2', 'SP', 'EP'], expected_ty_field: 'CONF') }
      it('does not contain the wrong fields') { ris_wrong_test(wrong_fields: ['BT', 'JO']) }

      context 'empty fields' do
        subject(:document) { described_class.new(attributes.merge('content_genre_ssi': 'Conference Paper', 'publisher_tesim': "", 'final_published_versions_tesim': "")) }

        it('does not contain empty fields') { ris_wrong_test(wrong_fields: ['PB', 'DO']) }
      end
    end

    describe 'with a genre of Poster' do
      subject(:document) { described_class.new(attributes.merge('content_genre_ssi': 'Poster')) }

      it('contains the right fields') { ris_right_test(right_fields: ['TY', 'TI', 'AU', 'LA', 'PY', 'PB', 'DO', 'T2', 'CY', 'L2'], expected_ty_field: 'GEN') }
      it('does not contain the wrong fields') { ris_wrong_test(wrong_fields: ['BT', 'JO', 'VL', 'IS', 'SP', 'EP']) }

      context 'empty fields' do
        subject(:document) { described_class.new(attributes.merge('content_genre_ssi': 'Poster', 'publisher_tesim': "", 'final_published_versions_tesim': "")) }

        it('does not contain empty fields') { ris_wrong_test(wrong_fields: ['PB', 'DO']) }
      end
    end

    describe 'with a genre of Presentation' do
      subject(:document) { described_class.new(attributes.merge('content_genre_ssi': 'Presentation')) }

      it('contains the right fields') { ris_right_test(right_fields: ['TY', 'TI', 'AU', 'LA', 'PY', 'PB', 'DO', 'T2', 'CY', 'L2'], expected_ty_field: 'GEN') }
      it('does not contain the wrong fields') { ris_wrong_test(wrong_fields: ['BT', 'JO', 'VL', 'IS', 'SP', 'EP']) }

      context 'empty fields' do
        subject(:document) { described_class.new(attributes.merge('content_genre_ssi': 'Presentation', 'publisher_tesim': "", 'final_published_versions_tesim': "")) }

        it('does not contain empty fields') { ris_wrong_test(wrong_fields: ['PB', 'DO']) }
      end
    end

    describe 'with a genre of Report' do
      subject(:document) { described_class.new(attributes.merge('content_genre_ssi': 'Report')) }

      it('contains the right fields') { ris_right_test(right_fields: ['TY', 'TI', 'AU', 'LA', 'PY', 'PB', 'DO', 'CY', 'L2'], expected_ty_field: 'REPORT') }
      it('does not contain the wrong fields') { ris_wrong_test(wrong_fields: ['BT', 'JO', 'T2', 'VL', 'IS', 'SP', 'EP']) }

      context 'empty fields' do
        subject(:document) { described_class.new(attributes.merge('content_genre_ssi': 'Report', 'publisher_tesim': "", 'final_published_versions_tesim': "")) }

        it('does not contain empty fields') { ris_wrong_test(wrong_fields: ['PB', 'DO']) }
      end
    end
  end
end
