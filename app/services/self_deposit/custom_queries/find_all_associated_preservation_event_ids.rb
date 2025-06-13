# frozen_string_literal: true
module SelfDeposit
  module CustomQueries
    # @example
    #
    #   Hyrax.custom_queries.find_all_associated_preservation_event_ids
    #
    # @see https://github.com/samvera/valkyrie/wiki/Queries#custom-queries
    class FindAllAssociatedPreservationEventIds < SolrDocumentMultipleReturnQuery
      self.queries = [:find_all_associated_preservation_event_ids]

      ##
      # @returns Array[PreservationEvents ids] or []
      def find_all_associated_preservation_event_ids
        return_array = []
        valkyrie_objects.each do |obj|
          obj.preservation_event_ids.split(',').each { |id| return_array += [id] } if obj.preservation_event_ids.present?
        end
        return_array
      end

      # Solr query for metadata objects with preservation_events_tesim values present.
      # @return query string.
      def query
        "preservation_events_tesim:*"
      end
    end
  end
end
