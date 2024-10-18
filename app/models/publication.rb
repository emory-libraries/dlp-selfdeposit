# frozen_string_literal: true
require './lib/preservation_event_model_methods'

# Generated via
#  `rails generate hyrax:work_resource Publication`
class Publication < Hyrax::Work
  include Hyrax::Schema(:emory_basic_metadata)
  include Hyrax::Schema(:publication_metadata)
  include PreservationEventModelMethods

  def add_preservation_workflow(workflow)
    raise TypeError "can't convert #{workflow.class} into PreservationWorkflow" unless workflow.is_a? PreservationWorkflow

    self.preservation_workflow_ids =
      preservation_workflow_ids.present? ? [preservation_workflow_ids, workflow.id.to_s].join(',') : workflow.id.to_s
  end

  def remove_preservation_workflow(workflow)
    raise TypeError "can't convert #{workflow.class} into PreservationWorkflow" unless workflow.is_a? PreservationWorkflow
    workflow_id = workflow.id.to_s

    Hyrax.persister.delete(resource: workflow)
    self.preservation_workflow_ids = preservation_workflow_ids.split(',').reject { |v| v == workflow_id }.join(',')
  end

  def preservation_workflows
    if preservation_workflow_ids.present?
      preservation_workflow_ids.split(',').map { |id| Hyrax.query_service.find_by(id:) }
    else
      []
    end
  end

  def file_sets
    Hyrax.custom_queries.find_child_file_sets(resource: self)
  end

  def primary_file_set
    file_sets&.find { |fs| fs.file_set_use == 'Primary Content' }
  end
end
