# frozen_string_literal: true
# [Hyrax-overwrite-v5.1] - Hyrax Bug!
#   `create_workflow_entity!` is called multiple times, so it must be made idempotent.

Rails.application.config.to_prepare do
  Hyrax::Workflow::WorkflowFactory.class_eval do
    private

    def create_workflow_entity!
      preexisting_entity = Sipity::Entity.find_by(proxy_for_global_id: Hyrax::GlobalID(work).to_s)
      if preexisting_entity.present?
        preexisting_entity.update(workflow: workflow_for(work), workflow_state: nil)
        preexisting_entity.reload
      else
        Sipity::Entity.create!(proxy_for_global_id: Hyrax::GlobalID(work).to_s,
                               workflow: workflow_for(work),
                               workflow_state: nil)
      end
    end
  end
end
