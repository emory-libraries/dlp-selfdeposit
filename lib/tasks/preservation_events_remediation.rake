# frozen_string_literal: true
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
      puts "Orphaned PreservationEvent IDs: #{orphaned_preservation_event_ids}" unless orphaned_preservation_event_ids.empty?
    end
  end
end
