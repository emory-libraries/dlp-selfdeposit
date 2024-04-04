# frozen_string_literal: true
namespace :selfdeposit do
  namespace :publications do
    desc "Bulk-import preservation workflow metadata for publications"
    task import_preservation_workflows: :environment do
      preservation_workflow_csv = Rails.root.join('config', 'preservation_workflow_metadata', 'preservation_workflows.csv')
      PreservationWorkflowImporter.import(preservation_workflow_csv)
    end
  end
end
