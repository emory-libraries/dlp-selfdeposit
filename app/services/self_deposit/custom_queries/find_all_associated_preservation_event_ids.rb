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
        @connection = Hyrax.index_adapter.connection
      end

      attr_reader :query_service

      ##
      # @returns [PreservationEvent#id]
      def find_all_associated_preservation_event_ids
        enum_for(:each)
      end

      # Queries the Solr index for all objects associated to PreservationEvent objects.
      # For each Document, it yields the list of pulled PreservationEvents' ids.
      # @yield [PreservationEvent#id]
      def each
        docs = Valkyrie::Persistence::Solr::Queries::DefaultPaginator.new
        while docs.has_next?
          docs = @connection.paginate(docs.next_page, docs.per_page, "select", params: { q: query })["response"]["docs"]
          docs.each do |doc|
            obj = query_service.find_by(id: doc['id'])
            obj.preservation_event_ids.split(',').each { |id| yield id }
          end
        end
      end

      # Solr query for metadata objects with preservation_events_tesim values present.
      # @return query string.
      def query
        "preservation_events_tesim:*"
      end
    end
  end
end
