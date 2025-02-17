# frozen_string_literal: true
module SelfDeposit
  module CustomQueries
    # @example
    #
    #   Hyrax.custom_queries.find_all_object_ids_lacking_preservation_events
    #
    # @see https://github.com/samvera/valkyrie/wiki/Queries#custom-queries
    class FindAllObjectIdsLackingPreservationEvents
      def self.queries
        [:find_all_object_ids_lacking_preservation_events]
      end

      def initialize(query_service:)
        @query_service = query_service
        @connection = Hyrax.index_adapter.connection
      end

      attr_reader :query_service

      ##
      # @returns [Publications#id, FileSets#id]
      def find_all_object_ids_lacking_preservation_events(model: nil)
        @model = model
        enum_for(:each)
      end

      # Queries the Solr index for Publication or FileSet (or specified model) object ids
      #   lacking an association to the PreservationEvent model.
      # For each Document, it yields the pulled object's ID string.
      # @yield ID string
      def each
        docs = Valkyrie::Persistence::Solr::Queries::DefaultPaginator.new
        while docs.has_next?
          docs = @connection.paginate(
            docs.next_page,
            docs.per_page,
            "select",
            params: {
              q: query,
              fq: @model.present? ? model_filter_query : default_filter_query
            }
          )["response"]["docs"]
          docs.each { |doc| yield doc['id'] }
        end
      end

      # Solr query for Publication or FileSet (or specified model) objects with
      #   no preservation_events_tesim values.
      # @return query string.
      def query
        "-preservation_events_tesim:["" TO *]"
      end

      def default_filter_query
        "has_model_ssim:Publication || has_model_ssim:FileSet"
      end

      def model_filter_query
        "has_model_ssim:#{@model}"
      end
    end
  end
end
