# frozen_string_literal: true
require 'rails_helper'
include Warden::Test::Helpers

RSpec.describe 'Bulkrax CSV importer', :clean_repo, type: :feature do
  context 'field mappings' do
    let(:pulled_field_mappings) { Bulkrax.field_mappings['Bulkrax::CsvParser'] }
    let(:all_mapped_fields) do
      ["abstract", "author_notes", "conference_name", "content_genre", "creator", "creator_last_first",
       "data_classification", "date_issued", "date_issue_year", "deduplication_key", "edition", "emory_content_type",
       "emory_ark", "file", "final_published_versions", "grant_agencies", "grant_information",
       "holding_repository", "institution", "internal_rights_note", "isbn", "issn", "issue", "keyword", "language",
       "license", "model", "page_range_end", "page_range_start", "parent", "parent_title", "place_of_production",
       "publisher", "publisher_version", "related_datasets", "research_categories", "rights_notes", "rights_statement",
       "series_title", "sponsor", "staff_notes", "subject", "system_of_record_ID", "title", "volume"]
    end
    let(:multiple_value_fields) do
      ["abstract", "creator", "creator_last_first", "emory_ark", "file", "final_published_versions",
       "grant_agencies", "grant_information", "keyword", "related_datasets", "research_categories", "rights_notes",
       "rights_statement", "staff_notes", "subject", "title"]
    end

    it 'maps the expected fields' do
      expect(pulled_field_mappings.count).to eq(45)
      expect(pulled_field_mappings.keys).to match_array(all_mapped_fields)
    end

    it 'contains the expected multivalue fields' do
      multivalued_fields = pulled_field_mappings.select { |_k, v| v[:split].present? }

      expect(multivalued_fields.count).to eq(16)
      expect(multivalued_fields.keys).to match_array(multiple_value_fields)
    end
  end

  context 'not logged in' do
    it 'redirects you to login when visiting dashboard ' do
      visit '/dashboard'
      expect(page.current_path).to include('/sign_in')
    end

    it 'redirects you to login when attempting to create new importer ' do
      visit '/importers/new'
      expect(page.current_path).to include('/sign_in')
    end
  end

  context 'logged in admin user' do
    let(:admin) { FactoryBot.create(:user) }
    let(:csv_file) { File.join(fixture_path, 'csv_import', 'Bulkrax_Test_CSV.csv') }

    before do
      # the below code adds the admin role to user
      Hyrax.index_adapter.wipe!
      admin.roles << Role.find_or_create_by(name: Hyrax.config.admin_user_group_name)
      admin.save
      login_as admin
    end

    context 'within importers/new' do
      before do
        visit '/importers/new'
        select('CSV - Comma Separated Values', from: 'Parser')
      end

      it 'has the expected CSV importer fields' do
        expect(find_all('.csv_fields div #importer_parser_fields_visibility option').map(&:text)).to match_array(
          ["Public", "Private", "Institution"]
        )
      end

      unless ENV['CI']
        it "has none of the other parser option's labels", js: true do
          expect(page).not_to have_css('.oai_fields .importer_parser_fields_base_url label', text: 'Base url')
          expect(page).not_to have_css('.bagit_fields .importer_parser_fields_metadata_file_name label', text: 'Metadata file name ')
          expect(page).not_to have_css('.xml_fields .importer_parser_fields_record_element label', text: 'Record element ')
        end
      end

      # This tests works when `js:true` is set, but that breaks in Circle CI.
      #   Will come back to this and fix Circle CI later.
      xit 'accepts a CSV to upload' do
        page.choose('Upload a File')
        attach_file('importer[parser_fields][file]', csv_file, make_visible: true)
        click_on('Create and Import')
      end
    end
  end
end
