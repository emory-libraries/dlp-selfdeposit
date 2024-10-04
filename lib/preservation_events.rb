# frozen_string_literal: true

# This module will be used to define preservation_event
# methods for work and fileset
module PreservationEvents
  # @param object - work or file_set object
  # @param event - hash with all event requirements (details, start, type, user, outcome, software_version)
  def create_preservation_event(object, event)
    persister = Hyrax.persister
    event = PreservationEvent.new(
      event_details: event['details'],
      event_end: event['end'] || DateTime.current,
      event_start: event['start'],
      event_type: event['type'],
      initiating_user: event['user'],
      outcome: event['outcome'],
      software_version: event['software_version']
    )

    event = persister.save(resource: event)
    object.add_preservation_event(event)

    # Persist preservation events to Fedora and Solr
    # Hyrax relies on listeners to persist data to Solr
    # Persisting data directly to Solr in this method was added for simplicity
    # If preservation event logic becomes more complex, consider adding another listener
    persister.save(resource: object)
    Hyrax.index_adapter.save(resource: object)

    event
  end

  def work_creation(event_start:, user_email:)
    { 'type' => 'Validation', 'start' => event_start, 'outcome' => 'Success', 'details' => 'Submission package validated',
      'software_version' => 'SelfDeposit v.1', 'user' => user_email }
  end

  def work_policy(event_start:, visibility:, user_email:)
    { 'type' => 'Policy Assignment', 'start' => event_start, 'outcome' => 'Success', 'software_version' => 'SelfDeposit v.1',
      'details' => "Visibility/access controls assigned: #{visibility}", 'user' => user_email }
  end

  def work_update(event_start:, user_email:)
    { 'type' => 'Modification', 'start' => event_start, 'outcome' => 'Success', 'details' => 'Object updated',
      'software_version' => 'SelfDeposit v.1', 'user' => user_email }
  end
end
