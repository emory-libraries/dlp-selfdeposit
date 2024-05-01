# frozen_string_literal: true
module SelfDeposit
  module CustomQueries
    # @example
    #   resource = Valkyrie Object
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
      # @param Valkyrie object for a Hyrax::Work
      #
      # @return Work Objects
      def find_parent_works(resource:)
        @resource = resource
        # query_service
        #   .find_all_of_model(model: resource.internal_resource.constantize)
        #   .find_all { |obj| obj.member_ids.map(&:to_s).include? resource.id.to_s }
        enum_for(:each)
      end

      # Queries for all Documents in the Solr index
      # For each Document, it yields the Valkyrie Resource which was converted from it
      # @yield [Valkyrie::Resource]
      def each
        docs = Valkyrie::Persistence::Solr::Queries::DefaultPaginator.new
        while docs.has_next?
          docs = @connection.paginate(docs.next_page, docs.per_page, "select", params: { q: query })["response"]["docs"]
          docs.each do |doc|
            yield Hyrax.query_service.find_by(id: doc['id'])
          end
        end
      end

      # Query Solr for for all documents with the ID in the requested field
      # @note the field used here is a _ssim dynamic field and the value is prefixed by "id-"
      # @return [Hash]
      def query
        "member_ids_ssim:#{@resource.id}"
      end
    end
  end
end
