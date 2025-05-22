# frozen_string_literal: true
module SelfDeposit
  module CustomQueries
    # @example
    #
    #   Hyrax.custom_queries.find_all_metadata_objects
    #
    # @see https://github.com/samvera/valkyrie/wiki/Queries#custom-queries
    class FindAllMetadataObjects
      def self.queries
        [:find_all_metadata_objects]
      end

      def initialize(query_service:)
        @query_service = query_service
        @solr_service = Hyrax::SolrService
      end

      attr_reader :query_service

      ##
      # @returns [Collections, Publications, FileSets]
      def find_all_metadata_objects
        valkyrie_objects_from_filter_query
      end

      def solr_documents_with_filter_query
        @solr_service
          &.query_result(query, fl: fields_selection, fq: filter_query, rows: 10_000_000)
          &.[]('response')
          &.[]('docs')
      end

      def valkyrie_objects_from_filter_query
        solr_documents_with_filter_query.map { |doc| query_service.find_by(id: doc['id']) }
      end

      # Solr query for for all objects
      # @return String
      def query
        "*:*"
      end

      # Solr filter query for for all metadata object types
      # @return String
      def filter_query
        "has_model_ssim:Publication || has_model_ssim:FileSet || has_model_ssim:CollectionResource"
      end

      def fields_selection
        "id"
      end
    end
  end
end
