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
        solr_documents_with_filter_query.map { |doc| doc['id'] }
      end

      # Solr query for objects with member_of_collections_ssim saved with `Unassigned` value
      # @return String
      def query
        "member_of_collections_ssim:Unassigned"
      end

      def filter_query
        "has_model_ssim:Publication"
      end
    end
  end
end
