# frozen_string_literal: true
# [Hyrax-override-v5.2.0] Adds method to pull total works found.

Rails.application.config.to_prepare do
  Hyrax::HomepagePresenter.class_eval do
    def total_works_deposited_count
      Hyrax.query_service.custom_queries.find_count_by_model
    end
  end
end
