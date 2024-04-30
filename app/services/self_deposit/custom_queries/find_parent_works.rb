# frozen_string_literal: true
module SelfDeposit
  module CustomQueries
    # @example
    #   resource = Valkyrie Object
    #
    #   Hyrax.custom_queries.find_parent_works(resource:)
    #
    # @see https://github.com/samvera/valkyrie/wiki/Queries#custom-queries
    class FindParentWorks
      def self.queries
        [:find_parent_works]
      end

      def initialize(query_service:)
        @query_service = query_service
      end

      attr_reader :query_service
      delegate :resource_factory, to: :query_service

      ##
      # @param Valkyrie object for a Hyrax::Work
      #
      # @return Work Objects
      def find_parent_works(resource:)
        query_service
          .find_all_of_model(model: resource.internal_resource.constantize)
          .find_all { |obj| obj.member_ids.map(&:to_s).include? resource.id.to_s }
      end
    end
  end
end
