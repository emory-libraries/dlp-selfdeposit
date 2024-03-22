# frozen_string_literal: true

require 'rails_helper'
require './lib/preservation_events'
include PreservationEvents

RSpec.describe PreservationEvents, :clean do
  let(:work) do
    work = Publication.new(
      data_classification: 'Public',
      deduplication_key: '123456',
      emory_content_type: 'Manuscript',
      holding_repository: 'Emory Libraries',
      creator: 'Dr. Seuss',
      rights_statement: 'http://rightsstatements.org/vocab/NoC-NC/1.0/'
    )

    Hyrax.persister.save(resource: work)
  end

  let(:start) { 1.day.ago }
  let(:end_time) { 10.minutes.ago }
  let(:event) do
    { 'type' => 'Policy Assignment', 'start' => start, 'end' => end_time,
      'details' => "Visibility/access controls assigned: Emory Network",
      'software_version' => 'SelfDeposit 1.0', 'user' => 'admin@example.com',
      'outcome' => 'Success' }
  end
  let(:saved_event) { create_preservation_event(work, event) }
  let(:queried_work) { Hyrax.query_service.find_by(id: work.id) }

  context '#create_preservation_event' do
    it 'returns a persisted PreservationEvent' do
      expect(saved_event).to be_a PreservationEvent
      expect(saved_event).to be_persisted
    end

    it 'adds PreservationEvent id to work attribute #preservation_event_ids' do
      saved_event

      expect(queried_work.preservation_event_ids).to eq saved_event.id
    end
  end
end
