# frozen_string_literal: true
module SelfDeposit
  ##
  # This class runs fixity checks on a {FileSetBehavior}, potentially on multiple
  # files each with multiple versions in the +FileSet+.
  #
  # The fixity check itself is performed by {FixityCheckJob}, which
  # just uses the fedora service to ask for fixity verification.
  # The outcome will be some created {ChecksumAuditLog} (ActiveRecord)
  # objects, recording the checks and their results.
  #
  # By default this runs the checks async using +ActiveJob+, so
  # returns no useful info -- the checks are still going Use
  # {ChecksumAuditLog.latest_for_file_set_id} to retrieve the latest
  # machine-readable checks.
  #
  # But if you initialize with +async_jobs: false+, checks will be done
  # blocking in foreground, and you can get back the {ChecksumAuditLog}
  # records created.
  #
  # It will only run fixity checks if there are not recent
  # {ChecksumAuditLog}s on record. "recent" is defined by
  # +max_days_between_fixity_checks+ arg, which defaults to configured
  # {Hyrax::Configuration#max_days_between_fixity_checks}
  class FileSetFixityCheckService
    attr_reader :id, :async_jobs, :max_days_between_fixity_checks

    # @param file_set [Valkyrie ID] file_set
    # @param async_jobs [Boolean] Run actual fixity checks in background. Default true.
    # @param max_days_between_fixity_checks [int] if an exisitng fixity check is
    #   recorded within this window, no new one will be created. Default
    #   {Hyrax::Configuration#max_days_between_fixity_checks}. Set to -1 to force
    #   check.
    # @param latest_version_only [Booelan]. Check only latest version instead of all
    #   versions. Default false.
    def initialize(file_set_id,
                   async_jobs: true,
                   max_days_between_fixity_checks: Hyrax.config.max_days_between_fixity_checks,
                   initiating_user:)
      @max_days_between_fixity_checks = max_days_between_fixity_checks || 0
      @async_jobs = async_jobs
      @initiating_user = initiating_user
      @id = file_set_id
      @file_set = Hyrax.query_service.find_by(id: @id)
    end

    # Fixity checks each version of each file if it hasn't been checked recently
    # If object async_jobs is false, will returns the set of most recent fixity check
    # status for each version of the content file(s). As a hash keyed by file_id,
    # values arrays of possibly multiple version checks.
    #
    # If async_jobs is true (default), just returns nil, stuff is still going on.
    def fixity_check
      results = fixity_check_file

      return if async_jobs
      results
    end

    private

    # Retrieve or generate the fixity check for a specific version of a file
    # @param [String] version_uri the version to be fixity checked (or the file uri for non-versioned files)
    def fixity_check_file
      latest_fixity_check = ChecksumAuditLog.logs_for(@id.to_s, checked_uri: @file_set.original_file.file_identifier.to_s.gsub('fedora', 'http')).first
      return latest_fixity_check unless needs_fixity_check?(latest_fixity_check)

      async_jobs ? FixityCheckJob.perform_later(file_set_id: @id, initiating_user: @initiating_user) : FixityCheckJob.perform_now(file_set_id: @id, initiating_user: @initiating_user)
    end

    # Check if time since the last fixity check is greater than the maximum days allowed between fixity checks
    # @param [ChecksumAuditLog] latest_fixity_check the most recent fixity check
    def needs_fixity_check?(latest_fixity_check)
      return true unless latest_fixity_check
      unless latest_fixity_check.updated_at
        logger.warn "***FIXITY*** problem with fixity check log! Latest Fixity check is not nil, but updated_at is not set #{latest_fixity_check}"
        return true
      end
      days_since_last_fixity_check(latest_fixity_check) >= max_days_between_fixity_checks
    end

    # Return the number of days since the latest fixity check
    # @param [ChecksumAuditLog] latest_fixity_check the most recent fixity check
    def days_since_last_fixity_check(latest_fixity_check)
      (DateTime.current - latest_fixity_check.updated_at.to_date).to_i
    end
  end
end
