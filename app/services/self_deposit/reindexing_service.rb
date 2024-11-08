# frozen_string_literal: true

module SelfDeposit
  class ReindexingService
    def self.reindex_all_metadata_objects
      all_objects = Hyrax.custom_queries.find_all_metadata_objects
      all_objects.each { |o| Hyrax.index_adapter.save(resource: o) }
    end
  end
end
