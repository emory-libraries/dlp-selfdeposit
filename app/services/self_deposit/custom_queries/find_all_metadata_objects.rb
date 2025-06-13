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
        valkyrie_objects_from_filter_query
      end

      # Solr filter query for for all metadata object types
      # @return String
      def filter_query
        "has_model_ssim:Publication || has_model_ssim:FileSet || has_model_ssim:CollectionResource"
      end
    end
  end
end
