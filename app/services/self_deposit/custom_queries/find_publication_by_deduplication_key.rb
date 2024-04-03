# frozen_string_literal: true
module SelfDeposit
  module CustomQueries
    # @example
    #   deduplication_key = 'jhqsdhdwhcolh'
    #
    #   Hyrax.custom_queries.find_publication_by_deduplication_key(deduplication_key:)
    #
    # @see https://github.com/samvera/valkyrie/wiki/Queries#custom-queries
    class FindPublicationByDeduplicationKey
      def self.queries
        [:find_publication_by_deduplication_key]
      end

      def initialize(query_service:)
        @query_service = query_service
      end

      attr_reader :query_service
      delegate :resource_factory, to: :query_service

      ##
      # @param deduplication_key for a Publication
      #
      # @return [Enumerable<PcdmCollection>]
      def find_publication_by_deduplication_key(deduplication_key:)
        query_service
          .find_all_of_model(model: ::Publication)
          .find { |publication| publication.deduplication_key == deduplication_key }
      end
    end
  end
end
