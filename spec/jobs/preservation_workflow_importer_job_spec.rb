# frozen_string_literal: true
require 'rails_helper'

RSpec.describe PreservationWorkflowImporterJob, :clean do
  let(:adapter)       { Valkyrie::MetadataAdapter.find(:test_adapter) }
  let(:persister)     { adapter.persister }
  let(:query_service) { adapter.query_service }
  let(:publication) do
    publication = Publication.new(
      data_classification: 'Public',
      emory_content_type: 'Manuscript',
      holding_repository: 'Emory Libraries',
      creator: 'Dr. Seuss',
      rights_statement: 'http://rightsstatements.org/vocab/NoC-NC/1.0/',
      deduplication_key: 'MSS1218_B071_I205',
      title: 'My Publication'
    )
    persister.save(resource: publication)
  end

  let(:csv) { fixture_path + '/preservation_workflows.csv' }

  before do
    PreservationWorkflowImporter.instance_variable_set(:@persister, persister)
    allow(Hyrax).to receive(:query_service).and_return(query_service)
    allow(Hyrax).to receive(:persister).and_return(persister)
    Hyrax.index_adapter.save(resource: publication)
  end

  after do
    Hyrax.index_adapter.wipe!
  end

  it 'processes preservation workflow metadata' do
    described_class.perform_now(csv)
    queried_publication = query_service.find_by(id: publication.id)
    expect(queried_publication.preservation_workflows.count).to eq 4
    expect(queried_publication.preservation_workflows.pluck(:workflow_type)).to match_array PreservationWorkflowImporter.workflow_types
  end
end
