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

  context 'alternate_ids_ssim' do
    let(:alternate_ids) { [double(id: 'alt_id_1'), double(id: 'alt_id_2')] }

    before do
      allow(resource).to receive(:alternate_ids).and_return(alternate_ids)
    end

    it 'contains an array of alternate IDs' do
      expect(indexer.to_solr['alternate_ids_ssim']).to eq(['alt_id_1', 'alt_id_2'])
    end
  end
end
