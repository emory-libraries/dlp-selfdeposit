# frozen_string_literal: true

# Generated via
#  `rails generate hyrax:work_resource Publication`
class Publication < Hyrax::Work
  include Hyrax::Schema(:emory_basic_metadata)
  include Hyrax::Schema(:publication_metadata)

  def add_preservation_event(event)
    raise TypeError "can't convert #{event.class} into PreservationEvent" unless event.is_a? PreservationEvent

    self.preservation_event_ids =
      preservation_event_ids.present? ? [preservation_event_ids, event.id.to_s].join(',') : event.id.to_s
  end

  def preservation_events
    if preservation_event_ids.present?
      preservation_event_ids.split(',').map { |id| Hyrax.query_service.find_by(id:) }
    else
      []
    end
  end
end
