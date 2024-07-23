# frozen_string_literal: true
module PreservationEventsHelper
  def sort_preservation_events(raw_events_json)
    return [] if raw_events_json.blank? || raw_events_json.empty?
    raw_events_json.map { |event_json| JSON.parse(event_json) }
                   .sort_by { |event| event['event_start'] }
                   .reverse
  end
end
