# frozen_string_literal: true
module SelfDeposit
  module CustomQueries
    # @example
    #   resource = Valkyrie Work Object
    #
    #   Hyrax.custom_queries.find_parent_works(resource:)
    #
    # @see https://github.com/samvera/valkyrie/wiki/Queries#custom-queries
    class FindParentWorks < SolrDocumentMultipleReturnQuery
      self.queries = [:find_parent_works]

      ##
      # @param Valkyrie object for a Hyrax Work type
      #
      # @return Array[Hyrax Work objects]
      def find_parent_works(resource:)
        @resource = resource
        valkyrie_objects
      end

      # Query Solr for for all documents with the ID in the member_ids_ssim field
      # @return [Hash]
      def query
        "member_ids_ssim:#{@resource.id}"
      end
    end
  end
end
