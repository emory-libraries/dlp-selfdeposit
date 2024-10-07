# frozen_string_literal: true
require 'rails_helper'

RSpec.describe CatalogController, type: :controller do
  let(:expected_show_fields) do
    ["alternate_ids_ssim", "content_genre_tesi", "title_tesim", "creator_tesim",
     "language_tesim", "date_issued_tesi", "publisher_tesim", "publisher_version_tesi",
     "parent_title_tesi", "conference_name_tesi", "issn_tesi", "isbn_tesi",
     "series_title_tesi", "grant_agencies_tesim", "grant_information_tesim",
     "abstract_tesim", "author_notes_tesi", "keyword_tesim", "subject_tesim",
     "research_categories_tesim", "emory_ark_tesim"]
  end

  describe 'show fields' do
    let(:show_fields) { controller.blacklight_config.show_fields.keys }

    it { expect(show_fields).to contain_exactly(*expected_show_fields) }
  end

  describe '"All Fields" solr fields' do
    let(:search_fields) do
      controller.blacklight_config.search_fields['all_fields'].solr_parameters[:qf].split(' ')
    end
    let(:default_hyrax_search_fields) { ["file_format_tesim", "all_text_timv"] }

    it { expect(search_fields).to match_array(expected_show_fields + default_hyrax_search_fields) }
  end
end
