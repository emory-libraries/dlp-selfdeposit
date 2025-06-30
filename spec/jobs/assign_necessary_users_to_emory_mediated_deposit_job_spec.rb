# frozen_string_literal: true
require 'rails_helper'
require 'hyrax/specs/shared_specs/factories/permission_templates'
require 'hyrax/specs/shared_specs/factories/administrative_sets'
require 'hyrax/specs/shared_specs/factories/workflows'

RSpec.describe AssignNecessaryUsersToEmoryMediatedDepositJob, :clean do
  let(:user) { FactoryBot.create(:user) }
  let(:admin_set) { FactoryBot.valkyrie_create(:hyrax_admin_set, title: ['OpenEmory Deposits with Workflow'], depositor: [user.user_key]) }
  let(:permission_template) { FactoryBot.create(:permission_template, source_id: admin_set.id) }
  let(:workflow) do
    FactoryBot.create(:workflow,
                      active: true,
                      permission_template_id: permission_template.id,
                      name: 'emory_mediated_deposit',
                      label: "SelfDeposit's mediated deposit workflow")
  end
  let(:depositing_role) { Sipity::Role.find_or_create_by(name: 'depositing') }
  let(:approving_role) { Sipity::Role.find_or_create_by(name: 'approving') }
  let(:managing_role) { Sipity::Role.find_or_create_by(name: 'managing') }

  before do
    Hyrax.index_adapter.wipe!
    [depositing_role, approving_role, managing_role].each { |role| workflow.workflow_roles.create(role: role) }
  end

  context 'user neither admin or with OE_Manager Role' do
    it "does not create any Sipity::WorkflowResponsibility" do
      expect { described_class.perform_now }.not_to change { Sipity::WorkflowResponsibility.count }
    end
  end

  context 'user is an admin' do
    before do
      user.roles << Role.find_or_create_by(name: Hyrax.config.admin_user_group_name)
      user.save
    end

    it "creates 3 Sipity::WorkflowResponsibility objects per user" do
      expect { described_class.perform_now }.to change { Sipity::WorkflowResponsibility.count }.by(3)
    end
  end

  context 'user has the OE_Manager role' do
    before do
      user.roles << Role.find_or_create_by(name: 'OE_Manager')
      user.save
    end

    it "creates 3 Sipity::WorkflowResponsibility objects per user" do
      expect { described_class.perform_now }.to change { Sipity::WorkflowResponsibility.count }.by(3)
    end
  end
end
