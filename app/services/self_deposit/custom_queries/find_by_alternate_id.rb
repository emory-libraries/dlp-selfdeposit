# frozen_string_literal: true
module SelfDeposit
  module CustomQueries
    class FindByAlternateId < SolrDocumentQuery
      def self.queries
        [:find_by_alternate_id]
      end

      def find_by_alternate_id(alternate_ids:)
        @alternate_id = alternate_ids
        raise ::Valkyrie::Persistence::ObjectNotFoundError unless resource
        @query_service.find_by(id: resource['id'])
      end

      def query
        "alternate_ids_ssim:#{@alternate_id}"
      end
    end
  end
end
