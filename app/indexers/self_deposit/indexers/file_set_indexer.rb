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
          solr_doc['file_path_ssim'] = object.file_path if object.file_path.present?
          solr_doc['creating_application_name_ssim'] = object.creating_application_name if object.creating_application_name.present?
          solr_doc['puid_ssim'] = object.puid if object.puid.present?
        end
      end
    end
  end
end
