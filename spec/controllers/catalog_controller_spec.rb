# frozen_string_literal: true
require 'rails_helper'

RSpec.describe CatalogController, type: :controller do
  include Devise::Test::ControllerHelpers

  expected_show_fields = ["alternate_ids_ssim", "content_genre_tesi", "title_tesim", "creator_tesim",
                          "language_tesim", "date_issued_tesi", "publisher_tesim", "publisher_version_tesi",
                          "parent_title_tesi", "conference_name_tesi", "issn_tesi", "isbn_tesi",
                          "series_title_tesi", "grant_agencies_tesim", "grant_information_tesim",
                          "abstract_tesim", "author_notes_tesi", "keyword_tesim", "subject_tesim",
                          "research_categories_tesim", "emory_ark_tesim"]

  describe 'show fields' do
    let(:show_fields) { controller.blacklight_config.show_fields.keys }

    it { expect(show_fields).to contain_exactly(*expected_show_fields) }
  end

  describe 'facet fields' do
    let(:expected_facet_fields) do
      ["creator_last_first_ssim", "date_issued_year_ssi", "parent_title_ssi", "content_genre_ssi", "publisher_version_ssi", "keyword_sim"]
    end

    it { expect(controller.blacklight_config.facet_fields.keys).to match_array(expected_facet_fields) }
  end

  describe 'index fields' do
    let(:expected_index_fields) do
      ["title_tesim", "creator_ssim", "date_issued_year_tesi", "publisher_tesim", "publisher_version_tesi", "license_tesi",
       "embargo_release_date_dtsi", "lease_expiration_date_dtsi", "all_text_tsimv"]
    end

    it { expect(controller.blacklight_config.index_fields.keys).to match_array(expected_index_fields) }
  end

  describe '"All Fields" solr fields' do
    let(:search_fields) do
      controller.blacklight_config.search_fields['all_fields'].solr_parameters[:qf].split(' ')
    end
    let(:default_hyrax_search_fields) { ["file_format_tesim", "all_text_tsimv"] }

    it { expect(search_fields).to match_array(expected_show_fields + default_hyrax_search_fields) }
  end

  context 'targeted search' do
    let(:bingo) { FactoryBot.valkyrie_create(:publication, title: ['Our Target Document'], read_groups: ['public']) }
    let!(:unrelated) { FactoryBot.valkyrie_create(:publication, :with_one_file_set, title: ['Unrelated'], read_groups: ['public']) }

    expected_show_fields.each do |field|
      before do
        Hyrax.index_adapter.wipe!
        bingo.send("#{field.split('_')[0..-2].join('_')}=", "Bingo")
        Hyrax.persister.save(resource: bingo)
        Hyrax.index_adapter.save(resource: bingo)
      end

      it 'finds works with the given search term' do
        get :index, params: { q: 'bingo', search_field: 'all_fields' }
        expect(response).to be_successful
        expect(response).to render_template('catalog/index')
        expect(assigns(:response).documents.map(&:id)).to contain_exactly(bingo.id)
      end
    end
  end
end
