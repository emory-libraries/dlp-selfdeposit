# frozen_string_literal: true
require 'rails_helper'
require 'hyrax/specs/shared_specs/indexers'
require 'hyrax/specs/shared_specs/factories/uploaded_files'
require 'hyrax/specs/shared_specs/factories/users'

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

  context 'file_set_use_ssi' do
    let(:resource) { ::FileSet.new(file_set_use: ::FileSet::PRIMARY) }

    it('contains the expected text') { expect(indexer.to_solr['file_set_use_ssi']).to eq('Primary Content') }
  end

  context 'original_checksum_ssim', storage_adapter: :memory do
    let(:file) { FactoryBot.create(:uploaded_file, file: File.open('spec/fixtures/world.png')) }
    let(:saved_file) do
      Hyrax.storage_adapter.upload(resource:,
                                   file: file.uploader.file,
                                   original_filename: file.uploader.filename)
    end
    let(:checksums) { ['urn:md5:blahblahblah', 'urn:sha256:blahblahblah', 'urn:sha1:blahblahblah'] }
    let(:file_metadata) { Hyrax.persister.save(resource: Hyrax::FileMetadata.new(original_checksum: checksums, file_identifier: saved_file.id)) }

    it 'contains the expected checksums' do
      Hyrax::ValkyrieUpload.new.add_file_to_file_set(file_set: resource, file_metadata:, user: User.new)

      expect(indexer.to_solr['original_checksum_ssim']).to match_array(checksums)
    end
  end
end
