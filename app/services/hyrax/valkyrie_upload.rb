# frozen_string_literal: true
# Hyrax v5.0.1: remove logic setting file set label and title from #upload method
# we have business logic that we implement upon file set creation in config/initializers/hyrax_work_uploads_handler_override.rb

class Hyrax::ValkyrieUpload
  # @param [IO] io
  # @param [String] filename
  # @param [Hyrax::FileSet] file_set
  # @param [Valkyrie::StorageAdapter] storage_adapter
  # @param [RDF::URI] use
  # @param [User] user
  #
  # @see Hyrax::FileMetadata::Use
  # @return [Hyrax::FileMetadata] the metadata representing the uploaded file
  # rubocop:disable Metrics/MethodLength
  # rubocop:disable Metrics/ParameterLists
  def self.file(
    filename:,
    file_set:,
    io:,
    storage_adapter: Hyrax.storage_adapter,
    use: Hyrax::FileMetadata::Use::ORIGINAL_FILE,
    user: nil
  )
    new(storage_adapter:)
      .upload(filename:, file_set:, io:, use:, user:)
  end

  ##
  # @!attribute [r] storage_adapter
  #   @return [Valkyrie::StorageAdapter] storage_adapter
  attr_reader :storage_adapter
  ##
  # @param [Valkyrie::StorageAdapter] storage_adapter
  # @param [Class] file_set_file_service implementer of {Hyrax::FileSetFileService}
  def initialize(storage_adapter: Hyrax.storage_adapter, file_set_file_service: Hyrax.config.file_set_file_service)
    @storage_adapter = storage_adapter
    @file_set_file_service = file_set_file_service
  end

  def upload(filename:, file_set:, io:, use: Hyrax::FileMetadata::Use::ORIGINAL_FILE, user: nil, mime_type: nil)
    return version_upload(file_set:, io:, user:) if use == Hyrax::FileMetadata::Use::ORIGINAL_FILE && file_set.original_file_id && storage_adapter.supports?(:versions)
    streamfile = storage_adapter.upload(file: io, original_filename: filename, resource: file_set)
    file_metadata = Hyrax::FileMetadata(streamfile)
    file_metadata.file_set_id = file_set.id
    file_metadata.pcdm_use = [use]
    file_metadata.recorded_size = [io.size]
    file_metadata.mime_type = mime_type if mime_type
    file_metadata.original_filename = File.basename(filename).to_s || File.basename(io)

    saved_metadata = Hyrax.persister.save(resource: file_metadata)
    saved_metadata.original_filename = filename if saved_metadata.original_filename.blank?

    add_file_to_file_set(file_set:,
                         file_metadata: saved_metadata,
                         user:)

    Hyrax.publisher.publish("file.uploaded", metadata: saved_metadata)
    Hyrax.publisher.publish('file.metadata.updated', metadata: saved_metadata, user:)

    saved_metadata
  end

  def version_upload(file_set:, io:, user:)
    file_metadata = @file_set_file_service.primary_file_for(file_set:)

    Hyrax::VersioningService.create(file_metadata, user, io)
    Hyrax.publisher.publish("file.uploaded", metadata: file_metadata)
    ContentNewVersionEventJob.perform_later(file_set, user)
  end

  # @param [Hyrax::FileSet] file_set the file set to add to
  # @param [Hyrax::FileMetadata] file_metadata the metadata object representing
  #   the file to add
  # @param [::User] user  the user performing the add
  #
  # @return [Hyrax::FileSet] updated file set
  def add_file_to_file_set(file_set:, file_metadata:, user:)
    file_set.file_ids += [file_metadata.id]
    Hyrax.persister.save(resource: file_set)
    Hyrax.publisher.publish('object.membership.updated', object: file_set, user:)
  end
end
