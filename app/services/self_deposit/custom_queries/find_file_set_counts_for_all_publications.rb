# frozen_string_literal: true
module SelfDeposit
  module CustomQueries
    # @example
    #
    #   Hyrax.custom_queries.find_file_set_counts_for_all_publications
    #
    # @see https://github.com/samvera/valkyrie/wiki/Queries#custom-queries
    class FindFileSetCountsForAllPublications < SolrDocumentMultipleReturnQuery
      self.queries = [:find_file_set_counts_for_all_publications]

      ##
      # @return Array[file set ids] or nil
      def find_file_set_counts_for_all_publications
        solr_documents
          &.map { |doc| [doc['deduplication_key_ssi'], doc['member_ids_ssim'].count] }
      end

      # Solr query for for Publications with value(s) in the member_ids_ssim field
      # @return String
      def query
        "has_model_ssim:Publication"
      end

      # Field(s) that the search results are restricted to
      # @return String
      def fields_selection
        "deduplication_key_ssi, member_ids_ssim"
      end
    end
  end
end
