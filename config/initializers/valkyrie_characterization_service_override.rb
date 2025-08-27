# frozen_string_literal: true
# [Hyrax-override-v5.2.0] We take over .run to create a PreservationEvent
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
      characterizer_obj.process_digest_preservation_event(
        saved.file_set_id, user, event_start, saved.original_checksum
      )
      Hyrax.publisher.publish('file.metadata.updated', metadata: saved, user:)
      Hyrax.publisher.publish('file.characterized',
                              file_set:,
                              file_id: saved.id.to_s,
                              path_hint: saved.file_identifier.to_s)
    end

    ##
    # @api private
    #
    # Coerce given source into a type that can be passed to Hydra::FileCharacterization
    # Use Hydra::FileCharacterization to extract metadata (an OM XML document)
    # Get the terms (and their values) from the extracted metadata
    # Assign the values of the terms to the properties of the metadata object
    #
    # @return [void]
    def characterize
      terms = parse_metadata(extract_metadata(content))
      transform_original_checksum(terms)
      apply_metadata(terms)
    end

    def transform_original_checksum(terms)
      value = terms[:original_checksum]

      return if value.empty?
      value.first.prepend("urn:md5:").to_s
      sha256 = digest_sha256
      sha1 = digest_sha1
      value.push(sha1, sha256)
    end

    def process_preservation_event(metadata, user, file_set, event_start)
      metadata_populated = check_for_populated_metadata(metadata)
      event = {
        'type' => 'Characterization',
        'start' => event_start,
        'outcome' => metadata_populated ? 'Success' : 'Failure',
        'details' => pres_event_details(metadata_populated, metadata, file_set),
        'software_version' => "FITS Servlet #{ENV.fetch('FITS_SERVLET_VERSION', 'v1.6.0')}",
        'user' => user&.email&.presence || file_set.depositor
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

    def digest_sha256
      sha = Digest::SHA256.new
      file = metadata.file

      file.rewind
      while (chunk = file.read(256))
        sha << chunk
      end
      sha.hexdigest.prepend("urn:sha256:")
    end

    def digest_sha1
      sha = Digest::SHA1.new
      file = metadata.file

      file.rewind
      while (chunk = file.read(1))
        sha << chunk
      end
      sha.hexdigest.prepend("urn:sha1:")
    end

    def process_digest_preservation_event(file_set_id, user, event_start, value)
      file_set = Hyrax.query_service.find_by(id: file_set_id)
      # create event for digest calculation/failure
      event = { 'type' => 'Message Digest Calculation', 'start' => event_start, 'details' => value,
                'software_version' => "FITS Servlet #{ENV.fetch('FITS_SERVLET_VERSION', 'v1.6.0')}, Fedora #{ENV.fetch('FEDORA_VERSION', 'v6.5.0')}, Ruby Digest library",
                'user' => user&.email&.presence || file_set.depositor }
      event['outcome'] = value.size == 3 ? 'Success' : 'Failure'

      create_preservation_event(file_set, event)
    end
  end
end
