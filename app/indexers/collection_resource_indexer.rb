# frozen_string_literal: true

# Generated via
#  `rails generate hyrax:collection_resource CollectionResource`
class CollectionResourceIndexer < Hyrax::PcdmCollectionIndexer
  include Hyrax::Indexer(:emory_basic_metadata)
  include Hyrax::Indexer(:collection_resource)
end
