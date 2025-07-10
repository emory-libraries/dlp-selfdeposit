# frozen_string_literal: true
# [Hyrax-override-v5.2.0] Adds or overrides value pull methods.

Rails.application.config.to_prepare do
  Hyrax::GoogleScholarPresenter.class_eval do
    EMORY_METHOD_ASSIGNMENTS = [
      ['publication_date', :date_issued_year],
      ['journal_title', :parent_title],
      ['conference_title', :conference_name],
      ['issn', :issn],
      ['isbn', :isbn],
      ['volume', :volume],
      ['issue', :issue],
      ['firstpage', :page_range_start],
      ['lastpage', :page_range_end]
    ].freeze

    EMORY_METHOD_ASSIGNMENTS.each do |method_name, solr_field|
      define_method method_name do
        object.try(solr_field)
      end
    end
  end
end
