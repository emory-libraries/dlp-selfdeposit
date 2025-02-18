# frozen_string_literal: true
module SelfDeposit
  module CustomQueries
    # @example
    #
    #   Hyrax.custom_queries.find_all_preservation_event_ids
    #
    # @see https://github.com/samvera/valkyrie/wiki/Queries#custom-queries
    class FindAllPreservationEventIds
      def self.queries
        [:find_all_preservation_event_ids]
      end

      def initialize(query_service:)
        @query_service = query_service
      end

      attr_reader :query_service

      ##
      # @returns [PreservationEvent#id]
      def find_all_preservation_event_ids
        query_service.custom_queries.find_ids_by_model(model: PreservationEvent)
      end
    end
  end
end
