# frozen_string_literal: true
# [Hyrax-overwrite-v5.0.1] - calls out rows to push past 10 results

Rails.application.config.to_prepare do
  Hyrax::ValkyrieAbstractTypeRelation.class_eval do
    def where(hash_or_string)
      case hash_or_string
      when String
        Hyrax::SolrService.query(hash_or_string, rows: 10_000_000_000)
      else
        Hyrax.query_service.find_references_by(resource: hash_or_string.values.first, property: hash_or_string.keys.first)
      end
    end
  end
end
