# frozen_string_literal: true
require 'rails_helper'
require 'hyrax/specs/shared_specs/factories/administrative_sets'
require 'hyrax/specs/shared_specs/factories/hyrax_collection'
require 'hyrax/specs/shared_specs/indexers'

RSpec.describe PublicationIndexer do
  shared_context 'with typical preservation_event' do
    before do
      allow(resource).to receive(:preservation_events).and_return([preservation_event])
    end
  end
  let(:indexer) { indexer_class.new(resource:) }
  let(:resource) { Publication.new }
  let(:indexer_class) { described_class }
  let(:preservation_event) { PreservationEvent.new(attributes) }
  let(:attributes) do
    { event_type: 'Reckoning',
      initiating_user: 'bilbo.baggins@example.com',
      event_start: '07/04/1776',
      event_end: '08/29/1997',
      outcome: 'Nothing',
      software_version: 'Cyberdine Systems T800',
      event_details: 'John Connor Lives' }
  end

  it_behaves_like 'a Hyrax::Resource indexer'

  context 'preservation_events_tesim' do
    include_context 'with typical preservation_event'

    it 'contains a json object of the PreservationEvent' do
      expect(indexer.to_solr['preservation_events_tesim']).to eq(
        ["{\"event_details\":\"John Connor Lives\",\"event_end\":\"08/29/1997\",\"event_start\":\"07/04/1776\",\"event_type\":\"Reckoning\"," \
         "\"initiating_user\":\"bilbo.baggins@example.com\",\"outcome\":\"Nothing\",\"software_version\":\"Cyberdine Systems T800\"}"]
      )
    end
  end

  context 'failed_preservation_events_ssim' do
    let(:preservation_event) { PreservationEvent.new(attributes.merge(outcome: 'Failure')) }
    include_context 'with typical preservation_event'

    it 'contains a failure-formatted json object of the PreservationEvent' do
      expect(indexer.to_solr['failed_preservation_events_ssim']).to eq(
        ["{\"event_details\":\"John Connor Lives\",\"event_start\":\"07/04/1776\"}"]
      )
    end
  end

  context 'preservation_workflow_terms_tesim' do
    let(:preservation_workflow) { PreservationWorkflow.new(attributes) }
    let(:attributes) do
      { workflow_type: 'example',
        workflow_notes: 'notes',
        workflow_rights_basis: 'rights basis',
        workflow_rights_basis_note: 'note',
        workflow_rights_basis_date: '02/02/2012',
        workflow_rights_basis_reviewer: 'reviewer',
        workflow_rights_basis_uri: 'uri' }
    end

    before do
      allow(resource).to receive(:preservation_workflows).and_return([preservation_workflow])
    end

    it 'contains a json object of the PreservationWorkflow' do
      expect(indexer.to_solr['preservation_workflow_terms_tesim']).to eq(
        ["{\"workflow_type\":\"example\",\"workflow_notes\":\"notes\",\"workflow_rights_basis\":\"rights basis\",\"workflow_rights_basis_note\":\"note\"," \
         "\"workflow_rights_basis_date\":\"02/02/2012\",\"workflow_rights_basis_reviewer\":\"reviewer\",\"workflow_rights_basis_uri\":\"uri\"}"]
      )
    end
  end

  context 'emory_persistent_id_ssi' do
    let(:emory_persistent_id) { 'alt_id_1' }

    before do
      allow(resource).to receive(:emory_persistent_id).and_return(emory_persistent_id)
    end

    it 'contains an array of alternate IDs' do
      expect(indexer.to_solr['emory_persistent_id_ssi']).to eq('alt_id_1')
    end
  end

  context 'member_of_collections_ssim' do
    it 'contains Unassigned when no id in member_of_collection_ids' do
      expect(indexer.to_solr['member_of_collections_ssim']).to eq(['Unassigned'])
    end

    describe 'when an id is in member_of_collection_ids' do
      let(:user) { FactoryBot.create(:user) }
      let(:admin_set) { FactoryBot.valkyrie_create(:hyrax_admin_set) }
      let(:collection_title) { ['The John Carpenter Collection'] }
      let(:collection) { FactoryBot.valkyrie_create(:hyrax_collection, title: collection_title) }

      before do
        allow(resource).to receive(:member_of_collection_ids).and_return([collection.id])
      end

      it 'contains expected title when id in member_of_collection_ids' do
        expect(indexer.to_solr['member_of_collections_ssim']).to eq(collection_title)
      end
    end
  end
end
