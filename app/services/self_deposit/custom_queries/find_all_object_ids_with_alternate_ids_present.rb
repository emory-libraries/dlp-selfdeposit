# frozen_string_literal: true
module SelfDeposit
  module CustomQueries
    # @example
    #
    #   Hyrax.custom_queries.find_all_object_ids_with_alternate_ids_present
    #
    # @see https://github.com/samvera/valkyrie/wiki/Queries#custom-queries
    class FindAllObjectIdsWithAlternateIdsPresent < SolrDocumentMultipleReturnQuery
      self.queries = [:find_all_object_ids_with_alternate_ids_present]

      ##
      # @return enumerator of Valkyrie Fedora objects
      def find_all_object_ids_with_alternate_ids_present
        solr_documents_with_filter_query
      end

      # Solr query for for a Publication with a deduplication_key_tesi that matches the provided key
      # @return [Hash]
      def query
        "alternate_ids_ssim:*"
      end

      def filter_query
        "has_model_ssim:Publication || has_model_ssim:FileSet || has_model_ssim:CollectionResource"
      end

      def fields_selection
        "alternate_ids_ssim, id"
      end
    end
  end
end
