# frozen_string_literal: true
require './lib/preservation_events'

# rubocop:disable Metrics/BlockLength
namespace :selfdeposit do
  namespace :preservation_events do
    desc "Identifies event objects not already associated to FileSets or Publications"
    task report_orphaned_objects: :environment do
      custom_queries = Hyrax.query_service.custom_queries
      all_preservation_event_ids = custom_queries&.find_all_preservation_event_ids&.to_a&.map(&:to_s)&.compact&.uniq
      associated_preservation_events_ids = custom_queries&.find_all_associated_preservation_event_ids&.to_a&.compact&.uniq
      orphaned_preservation_event_ids = all_preservation_event_ids - associated_preservation_events_ids

      puts "Number of PreservationEvent objects: #{all_preservation_event_ids.size}"
      puts "Number of associated PreservationEvent objects: #{associated_preservation_events_ids.size}"
      puts "Number of orphaned PreservationEvent objects: #{orphaned_preservation_event_ids.size}"
      if orphaned_preservation_event_ids.present?
        CSV.open('./tmp/orphaned_preservation_event_ids.csv', "wb") do |csv|
          csv << ['ids']
          orphaned_preservation_event_ids.each { |id| csv << Array(id) }
        end
      end
    end

    desc "Remediates Publication objects that lack PreservationEvent objects"
    task remediate_preservation_events_for_publications_lacking_them: :environment do
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
        puts "Preservation Events for Publication with ID #{id} have been remediated."
      end
    end

    desc "Removes orphaned PreservationEvent objects listed in a CSV"
    task remove_orphaned_preservation_events: :environment do
      csv_path = ENV['CSV_PATH']
      read_csv = CSV.open(csv_path, headers: true, return_headers: false)&.map(&:fields)&.flatten

      abort 'ERROR: CSV did not contain ids. Please check the file and try again.' if read_csv.empty?

      read_csv.each do |id|
        preservation_event = Hyrax.query_service.find_by(id:)
        if preservation_event.present?
          Hyrax.persister.delete(resource: preservation_event)
          puts "PreservationEvent with ID #{id} has been deleted."
        else
          puts "A PreservationEvent object with ID #{id} has not been found."
        end
      end

      puts "All orphaned PreservationEvent objects have been removed."
    end
  end
end
# rubocop:enable Metrics/BlockLength
