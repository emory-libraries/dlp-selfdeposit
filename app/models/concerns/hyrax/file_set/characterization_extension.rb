# frozen_string_literal: true
module Hyrax
  module FileSet
    module CharacterizationExtension
      extend ActiveSupport::Concern

      included do
        self.characterization_terms += [:file_path, :creating_application_name,
                                        :creating_os, :puid]
      end

      class SelfDepositSchema < ActiveTriples::Schema
        property :file_path, predicate: ::RDF::URI.new('http://metadata.emory.edu/vocab/cor-terms#filePath')
        property :creating_application_name, predicate: ::RDF::Vocab::PREMIS.hasCreatingApplicationName
        property :creating_os, predicate: ::RDF::URI.new('http://metadata.emory.edu/vocab/cor-terms#creatingOS')
        property :puid, predicate: ::RDF::URI.new('http://metadata.emory.edu/vocab/cor-terms#PUID')
      end

      ActiveFedora::WithMetadata::DefaultMetadataClassFactory.file_metadata_schemas << SelfDepositSchema
    end
  end
end
