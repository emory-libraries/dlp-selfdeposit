# frozen_string_literal: true
module SelfDeposit
  module CustomQueries
    # @example
    #
    #   Hyrax.custom_queries.find_all_file_set_ids_associated_to_publications
    #
    # @see https://github.com/samvera/valkyrie/wiki/Queries#custom-queries
    class FindAllFileSetIdsAssociatedToPublications < SolrDocumentMultipleReturnQuery
      self.queries = [:find_all_file_set_ids_associated_to_publications]

      ##
      # @return enumerator of Valkyrie Fedora objects
      def find_all_file_set_ids_associated_to_publications
        enum_for(:each)&.to_a&.flatten&.compact&.uniq
      end

      # Queries the Solr index for parent works of the provided resource
      # For each Document, it yields the pulled Hyrax Work object
      # @yield [Valkyrie::Resources]
      def each
        docs = Valkyrie::Persistence::Solr::Queries::DefaultPaginator.new
        while docs.has_next?
          docs = @connection.paginate(
                   docs.next_page, docs.per_page, "select", params: { q: query, fq: filter_query, fl: fields_selection }
                 )["response"]["docs"]
          docs.each { |doc| doc["member_ids_ssim"].each { |id| yield id } }
        end
      end

      # Solr query for for a Publication with a deduplication_key_tesi that matches the provided key
      # @return [Hash]
      def query
        "member_ids_ssim:*"
      end

      def filter_query
        "has_model_ssim:Publication"
      end

      def fields_selection
        "member_ids_ssim"
      end
    end
  end
end
