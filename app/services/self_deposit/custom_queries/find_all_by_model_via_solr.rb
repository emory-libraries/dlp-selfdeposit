# frozen_string_literal: true
module SelfDeposit
  module CustomQueries
    # @example
    #
    #   Hyrax.custom_queries.find_all_by_model_via_solr
    #
    # @see https://github.com/samvera/valkyrie/wiki/Queries#custom-queries
    class FindAllByModelViaSolr < SolrDocumentMultipleReturnQuery
      self.queries = [:find_all_by_model_via_solr]

      ##
      # @returns [PreservationEvent#id]
      def find_all_by_model_via_solr(model:)
        @model = model
        enum_for(:each)
      end

      # Solr query for metadata objects with preservation_events_tesim values present.
      # @return query string.
      def query
        "has_model_ssim:#{@model}"
      end
    end
  end
end
