# frozen_string_literal: true
module SelfDeposit
  module CustomQueries
    # @example
    #
    #   Hyrax.custom_queries.find_all_objects_with_alternate_ids_present
    #
    # @see https://github.com/samvera/valkyrie/wiki/Queries#custom-queries
    class FindAllObjectsWithAlternateIdsPresent
      def self.queries
        [:find_all_objects_with_alternate_ids_present]
      end

      def initialize(query_service:)
        @query_service = query_service
      end

      attr_reader :query_service

      ##
      # @return enumerator of Valkyrie Fedora objects
      def find_all_objects_with_alternate_ids_present
        enum_for(:each)
      end

      # Queries the Solr index for parent works of the provided resource
      # For each Document, it yields the pulled Hyrax Work object
      # @yield [Valkyrie::Resources]
      def each
        objects = @query_service.find_all
        objects.each do |obj|
          yield obj if obj.respond_to?(:alternate_ids) && obj.alternate_ids.present?
        end
      end
    end
  end
end
