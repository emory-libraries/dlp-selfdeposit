# frozen_string_literal: true
module SelfDeposit
  module CustomQueries
    # @example
    #   model: 'Publication' (default)
    #
    #   Hyrax.custom_queries.find_count_by_model(model:)
    #
    # @see https://github.com/samvera/valkyrie/wiki/Queries#custom-queries
    class FindCountByModel
      def self.queries
        [:find_count_by_model]
      end

      def initialize(query_service:)
        @query_service = query_service
        @connection = Hyrax.index_adapter.connection
      end

      ##
      # @param title for a Collection
      #
      # @return Collection
      def find_count_by_model(model: 'Publication')
        @model = model
        @connection.get("select", params: { q: query, fl: "*", rows: 1 })["response"]["numFound"]
      end

      # Solr query for for a Collection with a title_tesim that matches the provided key
      # @return [Hash]
      def query
        "has_model_ssim:#{@model}"
      end
    end
  end
end
