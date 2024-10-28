# frozen_string_literal: true

# Generated via
#  `rails generate hyrax:work_resource Publication`
class PublicationIndexer < Hyrax::Indexers::PcdmObjectIndexer(Publication)
  include Hyrax::Indexer(:emory_basic_metadata)
  include Hyrax::Indexer(:publication_metadata)

  # Uncomment this block if you want to add custom indexing behavior:
  def to_solr
    super.tap do |index_document|
      index_document[:failed_preservation_events_ssim] = failed_preservation_events
      index_document[:preservation_events_tesim] = resource&.preservation_events&.map(&:preservation_event_terms)
      index_document[:preservation_workflow_terms_tesim] = preservation_workflow_terms
      index_document[:alternate_ids_ssim] = find_alternate_ids
      index_document[:all_text_tsimv] = resource&.primary_file_set&.extracted_text_content
      index_document[:member_of_collections_ssim] = collection_names_for_facets
    end
  end

  private

  def failed_preservation_events
    failures = resource.preservation_events.select { |event| event.outcome == "Failure" }
    return if failures.blank?
    failures.map(&:failed_event_json)
  end

  def find_alternate_ids
    resource.alternate_ids.map(&:id)
  end

  def preservation_workflow_terms
    resource.preservation_workflows.map(&:preservation_terms)
  end

  def collection_names_for_facets
    resource&.member_of_collection_ids&.map { |id| Hyrax.query_service.find_by(id:)&.title&.first }&.presence || ['Unknown']
  end
end
