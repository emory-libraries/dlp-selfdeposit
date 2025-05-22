# frozen_string_literal: true
module SelfDeposit
  module CustomQueries
    # @example
    #
    #   Hyrax.custom_queries.find_all_object_ids_lacking_preservation_events
    #
    # @see https://github.com/samvera/valkyrie/wiki/Queries#custom-queries
    class FindAllObjectIdsLackingPreservationEvents
      def self.queries
        [:find_all_object_ids_lacking_preservation_events]
      end

      def initialize(query_service:)
        @query_service = query_service
        @solr_service = Hyrax::SolrService
      end

      attr_reader :query_service

      ##
      # @returns [Publications#id, FileSets#id]
      def find_all_object_ids_lacking_preservation_events(model: nil)
        @model = model
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

      # Solr query for objects with no preservation_events_tesim values.
      # @return String.
      def query
        "-preservation_events_tesim:['' TO *]"
      end

      # Solr filter query for either a certain class name or either Publication or FileSet, based on whether model was passed
      # @return String
      def filter_query
        @model.present? ? "has_model_ssim:#{@model}" : "has_model_ssim:Publication || has_model_ssim:FileSet"
      end

      def fields_selection
        "id"
      end
    end
  end
end
