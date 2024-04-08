# frozen_string_literal: true
require 'rails_helper'
require 'hyrax/specs/shared_specs/indexers'

RSpec.describe SelfDeposit::Indexers::FileSetIndexer do
  shared_context 'with typical preservation_event' do
    before do
      allow(resource).to receive(:preservation_events).and_return([preservation_event])
    end
  end
  let(:indexer) { indexer_class.new(resource:) }
  let(:resource) { ::FileSet.new }
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
end
