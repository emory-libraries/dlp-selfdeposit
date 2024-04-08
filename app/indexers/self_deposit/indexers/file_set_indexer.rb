# frozen_string_literal: true
module SelfDeposit
  module Indexers
    ##
    # Hyrax v5.0.0 Override - Adds our own customized Solr fields to accommodate PreservationEvent values.
    # Indexes ::FileSet objects
    class FileSetIndexer < Hyrax::Indexers::FileSetIndexer
      def to_solr
        super.tap do |solr_doc|
          solr_doc['preservation_events_tesim'] = resource&.preservation_events&.map(&:preservation_event_terms)
        end
      end
    end
  end
end
