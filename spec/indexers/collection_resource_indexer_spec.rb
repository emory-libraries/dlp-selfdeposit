# frozen_string_literal: true

# Generated via
#  `rails generate hyrax:work_resource CollectionResource`
require 'rails_helper'
require 'hyrax/specs/shared_specs/indexers'

RSpec.describe CollectionResourceIndexer do
  let(:indexer_class) { described_class }
  let(:resource)      { CollectionResource.new }
  let(:indexer)       { indexer_class.new(resource:) }

  it_behaves_like 'a Hyrax::Resource indexer'
  it_behaves_like 'a Basic metadata indexer'

  context 'emory_persistent_id_ssi' do
    let(:emory_persistent_id) { 'alt_id_1' }

    before do
      allow(resource).to receive(:emory_persistent_id).and_return(emory_persistent_id)
    end

    it 'contains an array of alternate IDs' do
      expect(indexer.to_solr['emory_persistent_id_ssi']).to eq('alt_id_1')
    end
  end
end
