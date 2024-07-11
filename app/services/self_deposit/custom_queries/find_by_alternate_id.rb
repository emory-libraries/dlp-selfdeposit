# frozen_string_literal: true
module SelfDeposit
  module CustomQueries
    class FindByAlternateId
      def self.queries
        [:find_by_alternate_id]
      end

      def initialize(query_service:)
        @query_service = query_service
        @connection = Hyrax.index_adapter.connection
      end

      attr_reader :query_service

      def find_by_alternate_id(alternate_ids:)
        @alternate_id = alternate_ids
        raise ::Valkyrie::Persistence::ObjectNotFoundError unless resource
        @query_service.find_by(id: resource['id'])
      end

      def resource
        @connection.get("select", params: { q: query, fl: "*", rows: 1 })["response"]["docs"].first
      end

      def query
        "alternate_ids_ssim:#{@alternate_id}"
      end
    end
  end
end
