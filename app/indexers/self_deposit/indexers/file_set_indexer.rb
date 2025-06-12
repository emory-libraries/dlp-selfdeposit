# frozen_string_literal: true
module SelfDeposit
  module Indexers
    ##
    # [Hyrax-override-v5.1 (ec2c524)] - Adds our own customized Solr fields to accommodate PreservationEvent values.
    # Indexes ::FileSet objects
    class FileSetIndexer < Hyrax::Indexers::FileSetIndexer
      include Hyrax::Indexer(:emory_file_set_metadata)

      def to_solr
        super.tap do |solr_doc|
          solr_doc['alternate_ids_ssim'] = find_alternate_ids
          solr_doc['preservation_events_tesim'] = resource&.preservation_events&.map(&:preservation_event_terms)

          file_metadata = Hyrax.config.file_set_file_service.new(file_set: resource).primary_file
          return solr_doc unless file_metadata

          solr_doc['file_path_ssim'] = file_metadata.file_path if file_metadata.file_path.present?
          solr_doc['creating_application_name_ssim'] = file_metadata.creating_application_name if file_metadata.creating_application_name.present?
          solr_doc['creating_os_ssim'] = file_metadata.creating_os if file_metadata.creating_os.present?
          solr_doc['puid_ssim'] = file_metadata.puid if file_metadata.puid.present?
          solr_doc['original_checksum_ssim'] = file_metadata.original_checksum if file_metadata.original_checksum.present?
        end
      end

      def find_alternate_ids
        resource.alternate_ids.map(&:id)
      end
    end
  end
end
