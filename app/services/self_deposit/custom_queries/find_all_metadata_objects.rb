# frozen_string_literal: true
module SelfDeposit
  module CustomQueries
    # @example
    #
    #   Hyrax.custom_queries.find_all_metadata_objects
    #
    # @see https://github.com/samvera/valkyrie/wiki/Queries#custom-queries
    class FindAllMetadataObjects < SolrDocumentMultipleReturnQuery
      self.queries = [:find_all_metadata_objects]

      ##
      # @returns [Collections, Publications, FileSets]
      def find_all_metadata_objects
        enum_for(:each)
      end

      # Queries the Solr index for all objects with library-created metadata
      # For each Document, it yields the pulled Hyrax Work object
      # @yield [Valkyrie::Resource]
      def each
        docs = Valkyrie::Persistence::Solr::Queries::DefaultPaginator.new
        while docs.has_next?
          docs = @connection.paginate(docs.next_page, docs.per_page, "select", params: { q: query, fq: filter_query })["response"]["docs"]
          docs.each do |doc|
            yield query_service.find_by(id: doc['id'])
          end
        end
      end

      # Solr query for for a Publication with a deduplication_key_tesi that matches the provided key
      # @return [Hash]
      def query
        "*:*"
      end

      def filter_query
        "has_model_ssim:Publication || has_model_ssim:FileSet || has_model_ssim:CollectionResource"
      end
    end
  end
end
