# frozen_string_literal: true
module SelfDeposit
  module CustomQueries
    class SolrDocumentMultipleReturnQuery
      def initialize(query_service:)
        @query_service = query_service
        @connection = Hyrax.index_adapter.connection
      end

      class_attribute :queries
      attr_reader :query_service

      # For each Document, it yields the instance of the model object.
      # @yield [<model instance>]
      def each
        docs = Valkyrie::Persistence::Solr::Queries::DefaultPaginator.new
        while docs.has_next?
          docs = @connection.paginate(docs.next_page, docs.per_page, "select", params: { q: query })["response"]["docs"]
          docs.each do |doc|
            yield query_service.find_by(id: doc['id'])
          end
        end
      end
    end
  end
end
