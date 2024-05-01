# frozen_string_literal: true
module SelfDeposit
  module CustomQueries
    # @example
    #   resource = Valkyrie Work Object
    #
    #   Hyrax.custom_queries.find_parent_works(resource:)
    #
    # @see https://github.com/samvera/valkyrie/wiki/Queries#custom-queries
    class FindParentWorks
      def self.queries
        [:find_parent_works]
      end

      def initialize(query_service:)
        @query_service = query_service
        @connection = Hyrax.index_adapter.connection
      end

      attr_reader :query_service

      ##
      # @param Valkyrie object for a Hyrax Work type
      #
      # @return enumerator of Hyrax Work objects
      def find_parent_works(resource:)
        @resource = resource
        enum_for(:each)
      end

      # Queries the Solr index for parent works of the provided resource
      # For each Document, it yields the pulled Hyrax Work object
      # @yield [Valkyrie::Resource]
      def each
        docs = Valkyrie::Persistence::Solr::Queries::DefaultPaginator.new
        while docs.has_next?
          docs = @connection.paginate(docs.next_page, docs.per_page, "select", params: { q: query })["response"]["docs"]
          docs.each do |doc|
            yield query_service.find_by(id: doc['id'])
          end
        end
      end

      # Query Solr for for all documents with the ID in the member_ids_ssim field
      # @return [Hash]
      def query
        "member_ids_ssim:#{@resource.id}"
      end
    end
  end
end
