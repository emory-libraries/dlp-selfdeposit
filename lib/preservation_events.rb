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
    persister.save(resource: object)
    event
  end
end
