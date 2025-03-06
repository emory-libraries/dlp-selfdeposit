# frozen_string_literal: true
# [Hyrax-overwrite-v5.0.1] - Adds method to pull total works found.

Rails.application.config.to_prepare do
  Hyrax::HomepagePresenter.class_eval do
    def total_works_deposited_count
      Hyrax.query_service.custom_queries.find_all_by_model_via_solr(model: Publication).count
    end
  end
end
