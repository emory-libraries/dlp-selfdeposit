# frozen_string_literal: true
require 'preservation_events'

class RemediateObjectsLackingPreservationEventsJob < Hyrax::ApplicationJob
  include PreservationEvents

  def perform
    query_service = Hyrax.query_service
    publication_ids_lacking_events = query_service&.custom_queries
                                                  &.find_all_object_ids_lacking_preservation_events(model: Publication)
                                                  &.to_a&.compact&.uniq

    publication_ids_lacking_events.each do |id|
      publication = query_service.find_by(id:)
      event_start = publication.created_at
      user_email = publication.depositor

      create_preservation_event(publication, work_creation(event_start:, user_email:))
      create_preservation_event(publication, work_policy(event_start:, visibility: publication.visibility, user_email:))
      Rails.logger.info("Preservation Events for Publication with ID #{id} have been remediated.")
    end
  end
end
