# frozen_string_literal: true
module SelfDeposit
  module CustomQueries
    # @example
    #
    #   Hyrax.custom_queries.find_all_object_ids_with_alternate_ids_present
    #
    # @see https://github.com/samvera/valkyrie/wiki/Queries#custom-queries
    class FindAllObjectIdsWithAlternateIdsPresent
      def self.queries
        [:find_all_object_ids_with_alternate_ids_present]
      end

      def initialize(query_service:)
        @query_service = query_service
        @connection = Hyrax.index_adapter.connection
      end

      attr_reader :query_service

      ##
      # @return enumerator of Valkyrie Fedora objects
      def find_all_object_ids_with_alternate_ids_present
        enum_for(:each)
      end

      # Queries the Solr index for parent works of the provided resource
      # For each Document, it yields the pulled Hyrax Work object
      # @yield [Valkyrie::Resources]
      def each
        docs = Valkyrie::Persistence::Solr::Queries::DefaultPaginator.new
        while docs.has_next?
          docs = @connection.paginate(docs.next_page, docs.per_page, "select", params: { q: query, fq: filter_query })["response"]["docs"]
          docs.each { |doc| yield doc['id'] }
        end
      end

      # Solr query for for a Publication with a deduplication_key_tesi that matches the provided key
      # @return [Hash]
      def query
        "alternate_ids_ssim:*"
      end

      def filter_query
        "has_model_ssim:Publication || has_model_ssim:FileSet || has_model_ssim:CollectionResource"
      end
    end
  end
end