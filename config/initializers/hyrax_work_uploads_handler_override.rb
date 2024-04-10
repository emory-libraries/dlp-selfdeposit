# frozen_string_literal: true
# [Hyrax-overwrite-v5.0.0] - We take over #make_file_set_and_ingest to create a
#   PreservationEvent registering the creation of a Publication's FileSet.
require './lib/preservation_events'

Rails.application.config.to_prepare do
  Hyrax::WorkUploadsHandler.class_eval do
    include PreservationEvents

    ##
    # @api private
    def make_file_set_and_ingest(file)
      event_start = DateTime.current
      file_name = file.file
      file_set = @persister.save(resource: ::FileSet.new(file_set_args(file)))
      Hyrax.publisher.publish('object.deposited', object: file_set, user: file.user)
      file_set_preservation_event(file_set, event_start, file_name, file.user.to_s)
      file.add_file_set!(file_set)

      # copy ACLs; should we also be propogating embargo/lease?
      Hyrax::AccessControlList.copy_permissions(source: target_permissions, target: file_set)

      # set visibility from params and save
      file_set.visibility = file_set_extra_params(file)[:visibility] if file_set_extra_params(file)[:visibility].present?
      file_set.permission_manager.acl.save if file_set.permission_manager.acl.pending_changes?
      append_to_work(file_set)

      { file_set:, user: file.user, job: ValkyrieIngestJob.new(file) }
    end

    # create preservation_event for fileset creation (method in PreservationEvents module)
    def file_set_preservation_event(file_set, event_start, file_name, user)
      outcome = file_set.persisted? ? 'Success' : 'Failure'
      formatted_file_name = file_name.to_s.split('/').last
      details = if file_set.persisted?
                  "#{formatted_file_name} submitted for preservation storage"
                else
                  "#{formatted_file_name} could not be submitted for preservation storage"
                end
      event = { 'type' => 'File submission', 'start' => event_start, 'outcome' => outcome, 'details' => details,
                'software_version' => 'Fedora v6', 'user' => user }

      create_preservation_event(file_set, event)
    end

    private

    ##
    # @api private
    #
    # @return [Hash{Symbol => Object}]
    def file_set_args(file)
      { depositor: file.user.user_key,
        creator: file.user.user_key,
        date_uploaded: file.created_at,
        date_modified: Hyrax::TimeService.time_in_utc,
        label: file.uploader.filename,
        title: file.uploader.filename,
        file_set_use: FileSet::PRIMARY }
    end
  end
end
