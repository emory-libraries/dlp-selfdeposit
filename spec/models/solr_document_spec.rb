# frozen_string_literal: true
require 'rails_helper'

RSpec.describe ::SolrDocument, type: :model do
  subject(:document) { described_class.new(attributes) }
  let(:attributes) { {} }

  shared_examples('tests for a direct solr index value return') do |method_name, solr_field, val|
    describe "##{method_name}" do
      let(:attributes) { { "#{solr_field}": [val] } }

      it 'returns the value from the solr document index' do
        expect(document.send(method_name)).to eq attributes[solr_field.to_sym]
      end
    end
  end

  include_examples('tests for a direct solr index value return',
                   'file_path',
                   'file_path_ssim',
                   '/usr/local/tomcat/webapps/fits/upload/1720036857165/halloween-kills.jpeg20240703-1-ed8o7o.jpeg')
  include_examples('tests for a direct solr index value return',
                   'creating_application_name',
                   'creating_application_name_ssim',
                   'ImageMagick')
  include_examples('tests for a direct solr index value return',
                   'creating_os',
                   'creating_os_ssim',
                   'MacOSX Sapphire')
  include_examples('tests for a direct solr index value return',
                   'persistent_unique_identification',
                   'puid_ssim',
                   'fmt/43')
  include_examples('tests for a direct solr index value return',
                   'original_checksum',
                   'original_checksum_ssim',
                   ["urn:sha1:8494cfb8d05e02b79ab6df1afe7545386a74bf39",
                    "urn:sha256:16b97ef201fa90417ff54157f67e180bcf7d2052cd55ced649d1cc20cddd22c9",
                    "urn:md5:9a553c8259a8ccfa80225dda33d7bf25"])
  include_examples('tests for a direct solr index value return',
                   'preservation_events',
                   'preservation_events_tesim',
                   '{\"event_details\":\"Visibility/access controls assigned: Emory Network\",\"event_end\":' \
                     '\"2024-07-08T15:36:11.455+00:00\",\"event_start\":\"2024-07-07T15:46:11.455+00:00\",\"event_type\":' \
                     '\"Policy Assignment\",\"initiating_user\":\"admin@example.com\",\"outcome\":\"Success\",' \
                     '\"software_version\":\"SelfDeposit 1.0\"}')
  include_examples('tests for a direct solr index value return',
                   'emory_persistent_id',
                   'emory_persistent_id_ssi',
                   '12345678-cor')
  include_examples('tests for a direct solr index value return',
                   'holding_repository',
                   'holding_repository_ssi',
                   'Emory University. Libraries')
  include_examples('tests for a direct solr index value return',
                   'institution',
                   'institution_ssi',
                   'Emory University')
  include_examples('tests for a direct solr index value return',
                   'contact_information',
                   'contact_information_ssi',
                   '4075555555')
  include_examples('tests for a direct solr index value return',
                   'subject_geo',
                   'subject_geo_ssim',
                   ['Atlanta, Georgia, USA'])
  include_examples('tests for a direct solr index value return',
                   'subject_names',
                   'subject_names_ssim',
                   ['Carter, Jimmy'])
  include_examples('tests for a direct solr index value return',
                   'notes',
                   'notes_ssim',
                   ['A note.'])
  include_examples('tests for a direct solr index value return',
                   'emory_ark',
                   'emory_ark_tesim',
                   ['doi:123456'])
  include_examples('tests for a direct solr index value return',
                   'system_of_record_ID',
                   'system_of_record_ID_ssi',
                   '12345678-cor')
  include_examples('tests for a direct solr index value return',
                   'staff_notes',
                   'staff_notes_tesim',
                   ['A note.'])
  include_examples('tests for a direct solr index value return',
                   'internal_rights_note',
                   'internal_rights_note_tesi',
                   'A note.')
  include_examples('tests for a direct solr index value return',
                   'administrative_unit',
                   'administrative_unit_ssi',
                   'Faculty')

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
        'final_published_versions_tesim': ['doi:123456'],
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

      it('contains the right fields') { ris_right_test(right_fields: ['TY', 'TI', 'AU', 'LA', 'PY', 'PB', 'DO', 'T2', 'VL', 'IS', 'CY', 'L2'], expected_ty_field: 'CONF') }
      it('does not contain the wrong fields') { ris_wrong_test(wrong_fields: ['BT', 'JO', 'SP', 'EP']) }

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
