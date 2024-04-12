# frozen_string_literal: true
module SelfDeposit
  module Indexers
    ##
    # Hyrax v5.0.0 Override - Adds our own customized Solr fields to accommodate PreservationEvent values.
    # Indexes ::FileSet objects
    class FileSetIndexer < Hyrax::Indexers::FileSetIndexer
      include Hyrax::Indexer(:emory_file_set_metadata)

      def to_solr
        super.tap do |solr_doc|
          solr_doc['preservation_events_tesim'] = resource&.preservation_events&.map(&:preservation_event_terms)

          file_metadata = Hyrax.config.file_set_file_service.new(file_set: resource).primary_file
          return solr_doc unless file_metadata

          solr_doc['original_checksum_ssim'] = file_metadata.original_checksum if file_metadata.original_checksum.present?
        end
      end
    end
  end
end
