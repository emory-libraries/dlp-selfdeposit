# frozen_string_literal: true
# [Hyrax-override-v5.1 (ec2c524)] Adds method to pull total works found.

Rails.application.config.to_prepare do
  Hyrax::HomepagePresenter.class_eval do
    def total_works_deposited_count
      Hyrax.query_service.custom_queries.find_count_by_model
    end
  end
end
