# frozen_string_literal: true
module SelfDeposit
  module CustomQueries
    # @example
    #   title = 'OpenEmory'
    #
    #   Hyrax.custom_queries.find_by_collection_title(title:)
    #
    # @see https://github.com/samvera/valkyrie/wiki/Queries#custom-queries
    class FindByCollectionTitle < SolrDocumentQuery
      self.queries = [:find_by_collection_title]

      ##
      # @param title for a Collection
      #
      # @return Collection
      def find_by_collection_title(title:)
        @title = title
        return nil unless resource
        @query_service.find_by(id: resource['id'])
      end

      # Solr query for for a Collection with a title_tesim that matches the provided key
      # @return [Hash]
      def query
        "has_model_ssim:CollectionResource && title_tesim:#{@title}"
      end
    end
  end
end
