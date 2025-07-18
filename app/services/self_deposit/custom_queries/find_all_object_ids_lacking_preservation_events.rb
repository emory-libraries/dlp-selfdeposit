# frozen_string_literal: true
module SelfDeposit
  module CustomQueries
    # @example
    #
    #   Hyrax.custom_queries.find_all_object_ids_lacking_preservation_events
    #
    # @see https://github.com/samvera/valkyrie/wiki/Queries#custom-queries
    class FindAllObjectIdsLackingPreservationEvents < SolrDocumentMultipleReturnQuery
      self.queries = [:find_all_object_ids_lacking_preservation_events]

      ##
      # @returns [Publications#id, FileSets#id]
      def find_all_object_ids_lacking_preservation_events(model: nil)
        @model = model
        solr_documents_with_filter_query
          &.map { |doc| doc[fields_selection] }
          &.flatten
          &.uniq
      end

      # Solr query for objects with no preservation_events_tesim values.
      # @return String.
      def query
        "-preservation_events_tesim:['' TO *]"
      end

      # Solr filter query for either a certain class name or either Publication or FileSet, based on whether model was passed
      # @return String
      def filter_query
        @model.present? ? "has_model_ssim:#{@model}" : "has_model_ssim:Publication || has_model_ssim:FileSet"
      end
    end
  end
end
