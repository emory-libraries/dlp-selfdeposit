# frozen_string_literal: true

# Generated via
#  `rails generate hyrax:collection_resource CollectionResource`
class CollectionResourceIndexer < Hyrax::PcdmCollectionIndexer
  include Hyrax::Indexer(:emory_basic_metadata)
  include Hyrax::Indexer(:collection_resource)

  # Uncomment this block if you want to add custom indexing behavior:
  # def to_solr
  #   super.tap do |index_document|
  #   end
  # end
end
