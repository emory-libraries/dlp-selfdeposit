# frozen_string_literal: true
class FixityCheckJob < Hyrax::ApplicationJob
  include PreservationEvents
  # A Job class that runs a fixity check (using Hyrax.config.fixity_service)
  # which contacts fedora and requests a fixity check), and stores the results
  # in an ActiveRecord ChecksumAuditLog row. It also prunes old ChecksumAuditLog
  # rows after creating a new one, to keep old ones you don't care about from
  # filling up your db.
  #
  # The uri passed in is a fedora URI that fedora can run fixity check on.
  # It's normally a version URI like:
  #     http://localhost:8983/fedora/rest/test/a/b/c/abcxyz/content/fcr:versions/version1
  #
  # But could theoretically be any URI fedora can fixity check on, like a file uri:
  #     http://localhost:8983/fedora/rest/test/a/b/c/abcxyz/content
  #
  # The file_set_id and file_id are used only for logging context in the
  # ChecksumAuditLog, and determining what old ChecksumAuditLogs can
  # be pruned.
  #
  # If calling async as a background job, return value is irrelevant, but
  # if calling sync with `perform_now`, returns the ChecksumAuditLog
  # record recording the check.
  #
  # @param file_set_id [FileSet] the id for FileSet parent object of URI being checked.
  def perform(file_set_id:, initiating_user:)
    event_start = DateTime.current
    @file_set = Hyrax.query_service.find_by(id: file_set_id)
    run_check.tap do |audit|
      result = audit.failed? ? :failure : :success

      announce_fixity_check_results(audit, result)
      file_set_preservation_event(audit.passed, event_start, initiating_user)
    end
  end

  private

  ##
  # @api private
  def run_check
    service = Hyrax.config.fixity_service.new(@file_set)
    expected_result = service.expected_message_digest

    ChecksumAuditLog.create_and_prune!(
      passed: service.check,
      file_set_id: @file_set.id.to_s,
      checked_uri: service.target.to_s,
      file_id: @file_set.original_file.id.to_s,
      expected_result: expected_result
    )
  rescue Hyrax::Fixity::MissingContentError
    ChecksumAuditLog.create_and_prune!(
      passed: false,
      file_set_id: @file_set.id.to_s,
      checked_uri: service.target.to_s,
      file_id: @file_set.original_file.id.to_s,
      expected_result: expected_result
    )
  end

  def announce_fixity_check_results(audit, result)
    Hyrax.publisher.publish('file.set.audited', file_set: @file_set, audit_log: audit, result:)

    # @todo remove this callback call for Hyrax 4.0.0
    process_failure_callback(audit) if should_call_failure_callback(audit)
  end

  def process_failure_callback(audit)
    Hyrax.config.callback.run(:after_fixity_check_failure,
                              @file_set,
                              checksum_audit_log: audit,
                              warn: false)
  end
  def should_call_failure_callback(audit)
    audit.failed? && Hyrax.config.callback.set?(:after_fixity_check_failure)
  end

  def file_set_preservation_event(log, event_start, initiating_user)
    logger = Logger.new(STDOUT)
    pulled_file_name = original_file_name
    pulled_checksum = original_file_checksum
    event = { 'type' => 'Fixity Check', 'start' => event_start, 'software_version' => 'Fedora v6.5.0', 'user' => initiating_user }

    if log == true
      event['outcome'] = 'Success'
      event['details'] = "Fixity intact for file: #{pulled_file_name}: sha1: #{pulled_checksum}"
      logger.info "Ran fixity check successfully on #{pulled_file_name}"
    else
      event['outcome'] = 'Failure'
      event['details'] = "Fixity check failed for: #{pulled_file_name}: sha1: #{pulled_checksum}"
      logger.error "Fixity check failure: Fixity failed for #{pulled_file_name}"
    end
    create_preservation_event(@file_set, event)
  end

  def original_file_name
    @file_set&.original_file&.title&.first || @file_set&.original_file&.label&.first || @file_set&.original_file&.original_filename
  end

  def original_file_checksum
    @file_set&.original_file&.original_checksum&.first
  end
end
