# frozen_string_literal: true
module SelfDeposit
  module CustomQueries
    class SolrDocumentQuery
      def initialize(query_service:)
        @query_service = query_service
        @connection = Hyrax.index_adapter.connection
      end

      class_attribute :queries
      attr_reader :query_service

      # Queries Solr for a document that matches the provided key
      # @yield [Publication]
      def resource
        @connection.get("select", params: { q: query, fl: "*", rows: 1 })["response"]["docs"].first
      end
    end
  end
end
