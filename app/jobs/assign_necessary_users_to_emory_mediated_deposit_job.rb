# frozen_string_literal: true

class AssignNecessaryUsersToEmoryMediatedDepositJob < Hyrax::ApplicationJob
  def perform
    workflow_agents.each do |agent|
      necessary_workflow_roles.each do |workflow_role|
        next if found_responsibility(agent_id: agent.id, workflow_role_id: workflow_role[1]).present?
        Sipity::WorkflowResponsibility.create!(agent: agent, workflow_role_id: workflow_role[1])
      end
    end
  end

  private

  def workflow_agents
    User.select { |u| u.admin? || u.roles.any? { |r| r.name == 'OE_Manager' } }.map(&:to_sipity_agent)
  end

  def workflow_role_options
    Sipity::WorkflowRole.all.map do |wf_role|
      [Hyrax::Admin::WorkflowRolePresenter.new(wf_role).label, wf_role.id]
    end
  end

  def necessary_workflow_roles
    workflow_role_options.select do |opt|
      opt.first.include?('OpenEmory Deposits with Workflow') && opt.first.include?('emory_mediated_deposit')
    end
  end

  def found_responsibility(agent_id:, workflow_role_id:)
    Sipity::WorkflowResponsibility.find_by_agent_id_and_workflow_role_id(agent_id, workflow_role_id)
  end
end
