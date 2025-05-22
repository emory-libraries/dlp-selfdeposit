# frozen_string_literal: true
module SelfDeposit
  module CustomQueries
    # @example
    #
    #   Hyrax.custom_queries.find_all_associated_preservation_event_ids
    #
    # @see https://github.com/samvera/valkyrie/wiki/Queries#custom-queries
    class FindAllAssociatedPreservationEventIds
      def self.queries
        [:find_all_associated_preservation_event_ids]
      end

      def initialize(query_service:)
        @query_service = query_service
        @solr_service = Hyrax::SolrService
      end

      attr_reader :query_service

      ##
      # @returns Array[PreservationEvents ids] or []
      def find_all_associated_preservation_event_ids
        return_array = []
        valkyrie_objects.each do |obj|
          obj.preservation_event_ids.split(',').each { |id| return_array += [id] } if obj.preservation_event_ids.present?
        end
        return_array
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

      # Solr query for metadata objects with preservation_events_tesim values present.
      # @return query string.
      def query
        "preservation_events_tesim:*"
      end

      # Field(s) that the search results are restricted to
      # @return String
      def fields_selection
        "id"
      end
    end
  end
end
