# frozen_string_literal: true
module SelfDeposit
  module CustomQueries
    # @example
    #
    #   Hyrax.custom_queries.find_all_publication_ids_unlinked_to_collection
    #
    # @see https://github.com/samvera/valkyrie/wiki/Queries#custom-queries
    class FindAllPublicationIdsUnlinkedToCollection
      def self.queries
        [:find_all_publication_ids_unlinked_to_collection]
      end

      def initialize(query_service:)
        @query_service = query_service
        @solr_service = Hyrax::SolrService
      end

      attr_reader :query_service

      ##
      # @returns [Publications#id, FileSets#id]
      def find_all_publication_ids_unlinked_to_collection
        solr_documents_with_filter_query.map { |doc| doc['id'] }
      end

      def solr_documents_with_filter_query
        @solr_service
          &.query_result(query, fl: fields_selection, fq: filter_query, rows: 10_000_000)
          &.[]('response')
          &.[]('docs')
      end

      # Solr query for objects with member_of_collections_ssim saved with `Unassigned` value
      # @return String
      def query
        "member_of_collections_ssim:Unassigned"
      end

      def filter_query
        "has_model_ssim:Publication"
      end

      def fields_selection
        "id"
      end
    end
  end
end
