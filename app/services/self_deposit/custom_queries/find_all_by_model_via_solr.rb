# frozen_string_literal: true
module SelfDeposit
  module CustomQueries
    # @example
    #
    #   Hyrax.custom_queries.find_all_by_model_via_solr
    #
    # @see https://github.com/samvera/valkyrie/wiki/Queries#custom-queries
    class FindAllByModelViaSolr
      def self.queries
        [:find_all_by_model_via_solr]
      end

      def initialize(query_service:)
        @query_service = query_service
        @connection = Hyrax.index_adapter.connection
      end

      attr_reader :query_service

      ##
      # @returns [PreservationEvent#id]
      def find_all_by_model_via_solr(model:)
        @model = model
        enum_for(:each)
      end

      # Queries the Solr index for all objects of a specified model.
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

      # Solr query for metadata objects with preservation_events_tesim values present.
      # @return query string.
      def query
        "has_model_ssim:#{@model}"
      end
    end
  end
end
