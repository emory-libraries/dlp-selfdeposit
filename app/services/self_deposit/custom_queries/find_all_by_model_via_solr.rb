# frozen_string_literal: true
module SelfDeposit
  module CustomQueries
    # @example
    #
    #   Hyrax.custom_queries.find_all_by_model_via_solr
    #
    # @see https://github.com/samvera/valkyrie/wiki/Queries#custom-queries
    class FindAllByModelViaSolr
      def self.queries
        [:find_all_by_model_via_solr]
      end

      def initialize(query_service:)
        @query_service = query_service
        @solr_service = Hyrax::SolrService
      end

      attr_reader :query_service

      ##
      # @returns [objects of a certain model]
      def find_all_by_model_via_solr(model:)
        @model = model
        valkyrie_objects
      end

      def solr_documents
        @solr_service
          &.query_result(query, fl: fields_selection, rows: 10_000_000)
          &.[]('response')
          &.[]('docs')
      end

      def valkyrie_objects
        solr_documents.map { |doc| query_service.find_by(id: doc['id']) }
      end

      # Solr query for all objects of a specified model
      # @return query string.
      def query
        "has_model_ssim:#{@model}"
      end

      # Field(s) that the search results are restricted to
      # @return String
      def fields_selection
        "id"
      end
    end
  end
end
