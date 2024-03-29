# frozen_string_literal: true

require "rails_helper"

RSpec.describe PreservationEvent do
  context "a new workflow" do
    let(:adapter)       { Valkyrie::MetadataAdapter.find(:test_adapter) }
    let(:persister)     { adapter.persister }
    let(:query_service) { adapter.query_service }
    let(:preservation_event) { described_class.new }

    let(:event_id) { 'wecpo-cwemclk-cvrroi' }
    let(:event_type) { "type" }
    let(:initiating_user) { "default user" }
    let(:event_start) { "2010-02-02" }
    let(:event_end) { "2010-02-03" }
    let(:outcome) { "passed" }
    let(:fileset_id) { "1232gfbad2221-cor" }
    let(:software_version) { "ClamXav 2.1.7" }
    let(:workflow_id) { "ewfmlkme-12312-cadcnel" }
    let(:event_details) { "special details" }

    it "can set a event_id" do
      preservation_event.event_id = event_id
      expect(preservation_event.event_id).to eq event_id
    end

    it "can set a event type" do
      preservation_event.event_type = event_type
      expect(preservation_event.event_type).to eq event_type
    end

    it "can set a initiating user" do
      preservation_event.initiating_user = initiating_user
      expect(preservation_event.initiating_user).to eq initiating_user
    end

    it "can set an event start" do
      preservation_event.event_start = event_start
      expect(preservation_event.event_start).to eq event_start
    end

    it "can set an event end" do
      preservation_event.event_end = event_end
      expect(preservation_event.event_end).to eq event_end
    end

    it "can set an outcome" do
      preservation_event.outcome = outcome
      expect(preservation_event.outcome).to eq outcome
    end

    it "can set a fileset id" do
      preservation_event.fileset_id = fileset_id
      expect(preservation_event.fileset_id).to eq fileset_id
    end

    it "can set a software version" do
      preservation_event.software_version = software_version
      expect(preservation_event.software_version).to eq software_version
    end

    it "can set a workflow id" do
      preservation_event.workflow_id = workflow_id
      expect(preservation_event.workflow_id).to eq workflow_id
    end

    it "can set event details" do
      preservation_event.event_details = event_details
      expect(preservation_event.event_details).to eq event_details
    end

    context 'class methods' do
      let(:different_event_start) { DateTime.current.strftime('%FT%T%:z') }
      let(:preservation_event) do
        event = described_class.new(
          event_type:,
          initiating_user:,
          event_start: different_event_start,
          event_end:,
          outcome:,
          software_version:,
          event_details:
        )

        persister.save(resource: event)
      end

      describe '#preservation_event_terms' do
        it 'creates a hash of preservation_event key/values in json' do
          expect(preservation_event.preservation_event_terms).to eq(
            "{\"event_details\":\"#{event_details}\",\"event_end\":\"#{event_end}\",\"event_start\":\"#{different_event_start}\",\"event_type\":\"#{event_type}\"" \
            ",\"initiating_user\":\"#{initiating_user}\",\"outcome\":\"#{outcome}\",\"software_version\":\"#{software_version}\"}"
          )
        end
      end

      describe '#failed_event_json' do
        it 'creates a hash of needed key/values for failed events in json' do
          expect(preservation_event.failed_event_json).to eq(
            "{\"event_details\":\"#{event_details}\",\"event_start\":\"#{different_event_start}\"}"
          )
        end
      end
    end
  end
end
