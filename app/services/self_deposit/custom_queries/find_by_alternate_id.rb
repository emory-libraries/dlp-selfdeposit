# frozen_string_literal: true
module SelfDeposit
  module CustomQueries
    # @example
    #   alternate_id = 'jhqsdh-emory'
    #
    #   Hyrax.custom_queries.find_by_alternate_id(alternate_ids:)
    #
    # @see https://github.com/samvera/valkyrie/wiki/Queries#custom-queries
    class FindByAlternateId
      def self.queries
        [:find_by_alternate_id]
      end

      def initialize(query_service:)
        @query_service = query_service
        @connection = Hyrax.index_adapter.connection
      end

      attr_reader :query_service

      ##
      # @param alternate_id for a Publication, Collection
      #
      # @return Publication or Collection
      def find_by_alternate_id(alternate_ids:)
        @alternate_id = alternate_ids
        raise ::Valkyrie::Persistence::ObjectNotFoundError unless resource
        @query_service.find_by(alternate_ids: resource['alternate_ids'])
      end

      # Queries Solr for a document that matches the provided alternate_id
      # @yield [Publication or Collection]
      def resource
        @connection.get("select", params: { q: query, fl: "*", rows: 1 })["response"]["docs"].first
      end

      # Solr query for for a Publication or Collaction with a alternate_ids_ssim that matches the provided id
      # @return [Hash]
      def query
        "alternate_ids_ssim:#{@alternate_id}"
      end
    end
  end
end
