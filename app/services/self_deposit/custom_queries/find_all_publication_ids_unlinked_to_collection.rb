# frozen_string_literal: true
module SelfDeposit
  module CustomQueries
    # @example
    #
    #   Hyrax.custom_queries.find_all_publication_ids_unlinked_to_collection
    #
    # @see https://github.com/samvera/valkyrie/wiki/Queries#custom-queries
    class FindAllPublicationIdsUnlinkedToCollection < SolrDocumentMultipleReturnQuery
      self.queries = [:find_all_publication_ids_unlinked_to_collection]

      ##
      # @returns [Publications#id, FileSets#id]
      def find_all_publication_ids_unlinked_to_collection
        enum_for(:each)&.to_a&.flatten&.compact&.uniq
      end

      # Queries the Solr index for Publication object ids with no Collection associated.
      # For each Document, it yields the pulled object's ID string.
      # @yield ID string
      def each
        docs = Valkyrie::Persistence::Solr::Queries::DefaultPaginator.new
        while docs.has_next?
          docs = @connection.paginate(docs.next_page, docs.per_page, "select", params: { q: query, fq: filter_query })["response"]["docs"]
          docs.each { |doc| yield doc['id'] }
        end
      end

      # Solr query for objects with member_of_collections_ssim saved with `Unassigned` value.
      # @return query string.
      def query
        "member_of_collections_ssim:Unassigned"
      end

      def filter_query
        "has_model_ssim:Publication"
      end
    end
  end
end
