# frozen_string_literal: true
module SelfDeposit
  module CustomQueries
    class SolrDocumentMultipleReturnQuery
      def initialize(query_service:)
        @query_service = query_service
        @solr_service = Hyrax::SolrService
      end

      class_attribute :queries
      attr_reader :query_service

      def solr_documents
        @solr_service
          &.query_result(query, fl: fields_selection, rows: 10_000_000)
          &.[]('response')
          &.[]('docs')
      end

      def solr_documents_with_filter_query
        @solr_service
          &.query_result(query, fl: fields_selection, fq: filter_query, rows: 10_000_000)
          &.[]('response')
          &.[]('docs')
      end

      def valkyrie_objects
        solr_documents.map { |doc| query_service.find_by(id: doc['id']) }
      end

      def valkyrie_objects_from_filter_query
        solr_documents_with_filter_query.map { |doc| query_service.find_by(id: doc['id']) }
      end

      def query
        "*:*"
      end

      def fields_selection
        "id"
      end
    end
  end
end
