# frozen_string_literal: true
require 'rails_helper'

RSpec.describe PreservationWorkflowImporter do
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

  let(:csv)          { fixture_path + '/preservation_workflows.csv' }
  let(:csv2)         { fixture_path + '/preservation_workflows2.csv' }

  describe "#import" do
    before do
      described_class.instance_variable_set(:@persister, persister)
      allow(Hyrax).to receive(:query_service).and_return(query_service)
      allow(Hyrax).to receive(:persister).and_return(persister)
      Hyrax.index_adapter.save(resource: publication)
      described_class.import(csv)
    end

    after do
      Hyrax.index_adapter.wipe!
    end

    context "with new preservation_workflow for the work" do
      it "creates new preservation_workflows" do
        queried_publication = query_service.find_by(id: publication.id)

        expect(queried_publication.preservation_workflows.count).to eq 4
        expect(queried_publication.preservation_workflows.pluck(:workflow_type)).to match_array described_class.workflow_types
      end

      ['Ingest', 'Accession'].each do |type|
        include_examples 'check_basis_reviewer_for_text', type, 'Scholarly Communications Office'
      end

      ['Deletion', 'Decommission'].each do |type|
        include_examples 'check_basis_reviewer_for_text', type, 'Woodruff Health Sciences Library Administration'
      end

      it 'populates the workflow_rights_basis_uri' do
        queried_publication = query_service.find_by(id: publication.id)
        rights_basis_uri_array = queried_publication.preservation_workflows.map(&:workflow_rights_basis_uri).uniq

        expect(rights_basis_uri_array).to eq ['https://someawesomewebsite.com']
      end
    end

    context "with existing preservation_workflow for the work" do
      before do
        described_class.import(csv2)
      end

      it "updates preservation_workflow" do
        queried_publication = query_service.find_by(id: publication.id)

        expect(queried_publication.preservation_workflows.count).to eq 4
      end

      include_examples 'check_basis_reviewer_for_text', 'Accession', 'LTDS'
    end
  end
end
