# frozen_string_literal: true
module SelfDeposit
  module CustomQueries
    # @example
    #
    #   Hyrax.custom_queries.find_all_file_set_ids_associated_to_publications
    #
    # @see https://github.com/samvera/valkyrie/wiki/Queries#custom-queries
    class FindAllFileSetIdsAssociatedToPublications
      def self.queries
        [:find_all_file_set_ids_associated_to_publications]
      end

      def initialize(query_service:)
        @query_service = query_service
        @solr_service = Hyrax::SolrService
      end

      attr_reader :query_service

      ##
      # @return Array[file set ids] or nil
      def find_all_file_set_ids_associated_to_publications
        @solr_service
          &.query_result(query, fl: fields_selection, rows: 10_000_000)
          &.[]('response')
          &.[]('docs')
          &.map { |doc| doc[fields_selection] }
          &.flatten
          &.uniq
      end

      # Solr query for for Publications with value(s) in the member_ids_ssim field
      # @return String
      def query
        "member_ids_ssim:* && has_model_ssim:Publication"
      end

      # Field(s) that the search results are restricted to
      # @return String
      def fields_selection
        "member_ids_ssim"
      end
    end
  end
end
