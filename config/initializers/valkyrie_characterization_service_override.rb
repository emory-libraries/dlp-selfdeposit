# frozen_string_literal: true
# [Hyrax-overwrite-v5.0.0] - We take over .run to create a PreservationEvent
#   registering the characterization of a Publication's FileSet.
require './lib/preservation_events'

Rails.application.config.to_prepare do
  Hyrax::Characterization::ValkyrieCharacterizationService.class_eval do
    include PreservationEvents

    ##
    # @api public
    # @param [Hyrax::FileMetadata] metadata  which has properties to recieve characterization values
    # @param [Valkyrie::StorageAdapter::StreamFile] source to run characterization against
    # @param [Hash] options the options pass to characterization
    # @option options [Hash{Symbol => Symbol}] parser_mapping
    # @option options [Hydra::Works::Characterization::FitsDocument] parser
    # @option options [Symbol] ch12n_tool
    #
    # @return [void]
    def self.run(metadata:, file:, user: ::User.system_user, **options)
      event_start = DateTime.current
      characterizer_obj = new(metadata:, file:, **options)
      characterizer_obj.characterize
      saved = Hyrax.persister.save(resource: metadata)
      file_set = Hyrax.query_service.find_by(id: saved.file_set_id)

      characterizer_obj.process_preservation_event(saved, user, file_set, event_start)
      Hyrax.publisher.publish('file.metadata.updated', metadata: saved, user:)
      Hyrax.publisher.publish('file.characterized',
                              file_set:,
                              file_id: saved.id.to_s,
                              path_hint: saved.file_identifier.to_s)
    end

    def process_preservation_event(metadata, user, file_set, event_start)
      metadata_populated = check_for_populated_metadata(metadata)
      event = {
        'type' => 'Characterization',
        'start' => event_start,
        'outcome' => metadata_populated ? 'Success' : 'Failure',
        'details' => pres_event_details(metadata_populated, metadata, file_set),
        'software_version' => 'FITS Servlet',
        'user' => user.presence || file_set.depositor
      }
      create_preservation_event(file_set, event)
    end

    def check_for_populated_metadata(metadata)
      ['height', 'width', 'checksum', 'recorded_size', 'format_label'].any? { |v| metadata.send(v).present? }
    end

    def pres_event_details(metadata_populated, metadata, file_set)
      return "#{file_set.characterization_proxy}: #{metadata.original_filename} - Technical metadata extracted from file, format identified, and file validated" if metadata_populated
      "The Characterization Service failed."
    end
  end
end
