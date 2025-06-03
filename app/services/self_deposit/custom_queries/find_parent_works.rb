# frozen_string_literal: true
module SelfDeposit
  module CustomQueries
    # @example
    #   resource = Valkyrie Work Object
    #
    #   Hyrax.custom_queries.find_parent_works(resource:)
    #
    # @see https://github.com/samvera/valkyrie/wiki/Queries#custom-queries
    class FindParentWorks
      def self.queries
        [:find_parent_works]
      end

      def initialize(query_service:)
        @query_service = query_service
        @solr_service = Hyrax::SolrService
      end

      attr_reader :query_service

      ##
      # @param Valkyrie object for a Hyrax Work type
      #
      # @return Array[Hyrax Work objects]
      def find_parent_works(resource:)
        @resource = resource
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

      # Query Solr for for all documents with the ID in the member_ids_ssim field
      # @return [Hash]
      def query
        "member_ids_ssim:#{@resource.id}"
      end

      def fields_selection
        "id"
      end
    end
  end
end
