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
        @connection = Hyrax.index_adapter.connection
      end

      attr_reader :query_service

      ##
      # @param deduplication_key for a Publication
      #
      # @return Publication
      def find_publication_by_deduplication_key(deduplication_key:)
        @deduplication_key = deduplication_key
        raise ::Valkyrie::Persistence::ObjectNotFoundError unless resource
        query_service.find_by(id: resource['id'])
      end

      # Queries Solr for a document that matches the provided key
      # @yield [Publication]
      def resource
        @resource ||= @connection.get("select", params: { q: query, fl: "*", rows: 1 })["response"]["docs"].first
      end

      # Solr query for for a Publication with a deduplication_key_tesi that matches the provided key
      # @return [Hash]
      def query
        "has_model_ssim:Publication && deduplication_key_tesi:#{@deduplication_key}"
      end
    end
  end
end
