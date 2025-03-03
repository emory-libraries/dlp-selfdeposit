# frozen_string_literal: true
require 'rails_helper'

RSpec.describe PreservationWorkflowImporterJob, :clean do
  let(:persister) { Hyrax.persister }
  let(:generic_work) do
    Hyrax.custom_queries.find_publication_by_deduplication_key(deduplication_key: 'MSS1218_B071_I205')
  end
  let(:csv) { fixture_path + '/preservation_workflows.csv' }

  before do
    work = GenericWork.new(
      title: ['Example title'],
      deduplication_key: 'MSS1218_B071_I205'
    )
    persister.save(resource: work)
  end

  it 'processes preservation workflow metadata' do
    described_class.perform_now(csv)
    expect(generic_work.preservation_workflow.count).to eq 4
  end
end
