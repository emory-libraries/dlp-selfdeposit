# frozen_string_literal: true
require 'preservation_events'

class RemediateObjectsLackingPreservationEventsJob < Hyrax::ApplicationJob
  include PreservationEvents

  def perform
    publication_ids_lacking_events = Hyrax.query_service
                                          &.custom_queries
                                          &.find_all_object_ids_lacking_preservation_events(model: Publication)
                                          &.to_a&.compact&.uniq

    process_lacking_publications(publication_ids: publication_ids_lacking_events)
  end

  private

  def process_lacking_publications(publication_ids:)
    publication_ids.each do |id|
      Rails.logger.info("Processing Preservation Events for Publication with ID #{id}.")
      publication = Hyrax.query_service.find_by(id:)
      event_start = publication.created_at
      user_email = publication.depositor

      create_preservation_event(publication, work_creation(event_start:, user_email:))
      create_preservation_event(publication, work_policy(event_start:, visibility: publication.visibility, user_email:))
      Rails.logger.info("Preservation Events for Publication with ID #{id} have been remediated.")
    rescue
      Rails.logger.error("A Publication with ID #{id} was not found.")
      next
    end
  end
end
