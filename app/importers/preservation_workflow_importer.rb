# frozen_string_literal: true
require 'csv'

class PreservationWorkflowImporter
  @workflow_types = ['Ingest', 'Accession', 'Deletion', 'Decommission']
  @persister = Hyrax.persister
  class << self
    attr_reader :workflow_types

    def import(csv_file, log_location = STDOUT)
      CSV.foreach(csv_file, headers: true) do |row|
        workflow_attrs = row.to_hash
        # ignore file_sets and check if workflows actually have values
        next unless workflow_attributes_present(workflow_attrs)
        publication = Hyrax.custom_queries.find_publication_by_deduplication_key(deduplication_key: workflow_attrs['deduplication_key'])
        check_workflows_exists?(publication)
        @workflow_types.each { |type| create_workflow(type, publication, workflow_attrs) }
        @persister.save(resource: publication)
        @logger = Logger.new(log_location)
        @logger.info "Updated preservation_workflow for #{publication.title.first}"
      end
    end

    private

    def check_workflows_exists?(publication)
      @workflow_types.each do |type|
        found_publication_workflow = publication.preservation_workflows.find { |w| w.workflow_type == type }
        publication.remove_preservation_workflow(found_publication_workflow) if found_publication_workflow # we first delete existing workflow and then update
      end
    end

    def create_workflow(type, publication, workflow_attrs)
      workflow = PreservationWorkflow.new(
        workflow_type: type,
        workflow_notes: workflow_attrs["#{type}.workflow_notes"].presence || workflow_attrs["#{type}.workflow_note"],
        workflow_rights_basis: workflow_attrs["#{type}.workflow_rights_basis"],
        workflow_rights_basis_note: workflow_attrs["#{type}.workflow_rights_basis_note"],
        workflow_rights_basis_date: workflow_attrs["#{type}.workflow_rights_basis_date"],
        workflow_rights_basis_reviewer: workflow_attrs["#{type}.rights_basis_reviewer"].presence || workflow_attrs["#{type}.workflow_rights_basis_reviewer"],
        workflow_rights_basis_uri: workflow_attrs["#{type}.workflow_rights_basis_uri"]
      )

      saved_workflow = @persister.save(resource: workflow)
      publication.add_preservation_workflow(saved_workflow)
    end

    def workflow_attributes_present(workflow_attrs)
      workflow_attrs['type'] == 'publication' && workflow_attrs['deduplication_key'].present? && workflow_attrs.values.compact.count > 2
    end
  end
end
