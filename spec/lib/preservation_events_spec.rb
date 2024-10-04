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
  start_time = 1.day.ago
  let(:end_time) { 10.minutes.ago }
  let(:saved_event) { create_preservation_event(work, event) }
  let(:queried_work) { Hyrax.query_service.find_by(id: work.id) }

  shared_context 'with a preservation_event hash' do |policy|
    let(:event) do
      policy['end'] = end_time
      policy
    end
  end

  shared_examples 'tests expected values of a PreservationEvent' do |method_name, expected_details, expected_type, start|
    it "contains the expected values (#{method_name})" do
      expect(saved_event.event_details).to eq(expected_details)
      expect(saved_event.event_end).to eq(end_time)
      expect(saved_event.event_start).to eq(start)
      expect(saved_event.event_type).to eq(expected_type)
      expect(saved_event.initiating_user).to eq('admin@example.com')
      expect(saved_event.outcome).to eq('Success')
      expect(saved_event.software_version).to eq('SelfDeposit v.1')
    end
  end

  include_context(
    'with a preservation_event hash', work_policy(event_start: start_time, visibility: 'Emory Network', user_email: 'admin@example.com')
  )

  context '#create_preservation_event' do
    it 'returns a persisted PreservationEvent' do
      expect(saved_event).to be_a PreservationEvent
      expect(saved_event).to be_persisted
    end

    include_examples(
      'tests expected values of a PreservationEvent',
      'work_policy',
      'Visibility/access controls assigned: Emory Network',
      'Policy Assignment',
      start_time
    )

    context 'work_creation type of event' do
      include_context(
        'with a preservation_event hash', work_creation(event_start: start_time, user_email: 'admin@example.com')
      )

      include_examples(
        'tests expected values of a PreservationEvent', 'work_creation', 'Submission package validated', 'Validation', start_time
      )
    end

    context 'work_update type of event' do
      include_context(
        'with a preservation_event hash', work_update(event_start: start_time, user_email: 'admin@example.com')
      )

      include_examples('tests expected values of a PreservationEvent', 'work_update', 'Object updated', 'Modification', start_time)
    end

    it 'adds PreservationEvent id to work attribute #preservation_event_ids' do
      saved_event

      expect(queried_work.preservation_event_ids).to eq saved_event.id
    end
  end
end
