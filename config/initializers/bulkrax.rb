# frozen_string_literal: true

Bulkrax.setup do |config|
  # Add local parsers
  # config.parsers += [
  #   { name: 'MODS - My Local MODS parser', class_name: 'Bulkrax::ModsXmlParser', partial: 'mods_fields' },
  # ]

  # WorkType to use as the default if none is specified in the import
  # Default is the first returned by Hyrax.config.curation_concerns, stringified
  # config.default_work_type = "MyWork"

  # Factory Class to use when generating and saving objects
  # config.object_factory = Bulkrax::ObjectFactory
  # Use this for a Postgres-backed Valkyrized Hyrax
  config.object_factory = Bulkrax::ValkyrieObjectFactory

  # Path to store pending imports
  # config.import_path = 'tmp/imports'

  # Path to store exports before download
  # config.export_path = 'tmp/exports'

  # Server name for oai request header
  # config.server_name = 'my_server@name.com'

  # NOTE: Creating Collections using the collection_field_mapping will no longer be supported as of Bulkrax version 3.0.
  #       Please configure Bulkrax to use related_parents_field_mapping and related_children_field_mapping instead.
  # Field_mapping for establishing a collection relationship (FROM work TO collection)
  # This value IS NOT used for OAI, so setting the OAI parser here will have no effect
  # The mapping is supplied per Entry, provide the full class name as a string, eg. 'Bulkrax::CsvEntry'
  # The default value for CSV is collection
  # Add/replace parsers, for example:
  # config.collection_field_mapping['Bulkrax::RdfEntry'] = 'http://opaquenamespace.org/ns/set'

  # Field mappings
  # Create a completely new set of mappings by replacing the whole set as follows
  config.field_mappings = {
    "Bulkrax::CsvParser" => {
      "abstract" => { from: ["abstract"], split: '\|', join: '|' },
      "access_right" => { from: ["access_right"], split: '\|', join: '|' },
      "author_notes" => { from: ["author_notes"] },
      "conference_name" => { from: ["conference_name"] },
      "content_genre" => { from: ["content_genre"] },
      "creator" => { from: ["creator"], split: '\|', join: '|' },
      "data_classification" => { from: ["data_classification"] },
      "date_issued" => { from: ["date_issued"] },
      "deduplication_key" => { from: ["deduplication_key"], source_identifier: true, search_field: 'deduplication_key_ssi' },
      "edition" => { from: ["edition"] },
      "emory_content_type" => { from: ["emory_content_type"] },
      "emory_ark" => { from: ["emory_ark"], split: '\|', join: '|' },
      "file" => { from: ["file"], split: '\;', join: ';' },
      "final_published_versions" => { from: ["final_published_versions"], split: '\|', join: '|' },
      "grant_agencies" => { from: ["grant_agencies"], split: '\|', join: '|' },
      "grant_information" => { from: ["grant_information"], split: '\|', join: '|' },
      "holding_repository" => { from: ["holding_repository"] },
      "institution" => { from: ["institution"] },
      "internal_rights_note" => { from: ["internal_rights_note"] },
      "isbn" => { from: ["isbn"] },
      "issn" => { from: ["issn"] },
      "issue" => { from: ["issue"] },
      "keyword" => { from: ["keyword"], split: '\|', join: '|' },
      "language" => { from: ["language"] },
      "license" => { from: ["license"] },
      "model" => { from: ["model"], join: '|' },
      "page_range_end" => { from: ["page_range_end"] },
      "page_range_start" => { from: ["page_range_start"] },
      "parent" => { from: ["parent"], related_parents_field_mapping: true },
      "parent_title" => { from: ["parent_title"] },
      "place_of_production" => { from: ["place_of_production"] },
      "publisher" => { from: ["publisher"], split: '\|', join: '|' },
      "publisher_version" => { from: ["publisher_version"] },
      "related_datasets" => { from: ["related_datasets"], split: '\|', join: '|' },
      "research_categories" => { from: ["research_categories"], split: '\|', join: '|' },
      "rights_statement" => { from: ["rights_statement"], split: '\|', join: '|' },
      "series_title" => { from: ["series_title"] },
      "sponsor" => { from: ["sponsor"] },
      "staff_notes" => { from: ["staff_notes"], split: '\|', join: '|' },
      "subject" => { from: ["subject"], split: '\|', join: '|' },
      "system_of_record_ID" => { from: ["system_of_record_ID"] },
      "title" => { from: ["title"], split: '\|', join: '|' },
      "volume" => { from: ["volume"] }
    }
  }

  # Add to, or change existing mappings as follows
  #   e.g. to exclude date
  #   config.field_mappings["Bulkrax::OaiDcParser"]["date"] = { from: ["date"], excluded: true  }
  #
  #   e.g. to import parent-child relationships
  #   config.field_mappings['Bulkrax::CsvParser']['parents'] = { from: ['parents'], related_parents_field_mapping: true }
  #   config.field_mappings['Bulkrax::CsvParser']['children'] = { from: ['children'], related_children_field_mapping: true }
  #   (For more info on importing relationships, see Bulkrax Wiki: https://github.com/samvera-labs/bulkrax/wiki/Configuring-Bulkrax#parent-child-relationship-field-mappings)
  #
  # #   e.g. to add the required source_identifier field
  #   #   config.field_mappings["Bulkrax::CsvParser"]["source_id"] = { from: ["old_source_id"], source_identifier: true, search_field: 'source_id_sim' }
  # If you want Bulkrax to fill in source_identifiers for you, see below

  # To duplicate a set of mappings from one parser to another
  #   config.field_mappings["Bulkrax::OaiOmekaParser"] = {}
  #   config.field_mappings["Bulkrax::OaiDcParser"].each {|key,value| config.field_mappings["Bulkrax::OaiOmekaParser"][key] = value }

  # Should Bulkrax make up source identifiers for you? This allow round tripping
  # and download errored entries to still work, but does mean if you upload the
  # same source record in two different files you WILL get duplicates.
  # It is given two aruguments, self at the time of call and the index of the reocrd
  config.fill_in_blank_source_identifiers = ->(obj, index) { "SelfDeposit-#{obj.importerexporter.id}-#{index}" }

  # Properties that should not be used in imports/exports. They are reserved for use by Hyrax.
  # config.reserved_properties += ['my_field']

  # List of Questioning Authority properties that are controlled via YAML files in
  # the config/authorities/ directory. For example, the :rights_statement property
  # is controlled by the active terms in config/authorities/rights_statements.yml
  # Defaults: 'rights_statement' and 'license'
  # config.qa_controlled_properties += ['my_field']

  # Specify the delimiter regular expression for splitting an attribute's values into a multi-value array.
  # config.multi_value_element_split_on = /\s*[:;|]\s*/.freeze

  # Specify the delimiter for joining an attribute's multi-value array into a string.  Note: the
  # specific delimeter should likely be present in the multi_value_element_split_on expression.
  # config.multi_value_element_join_on = ' | '
end

# Bulkrax v8.1.0 Override - L#147 had a typo (custom_query instead of custom_queries). `find_by_model_and_property_value` as
#   it currently exists in Bulkrax uses SQL, which makes it Postgres-only. It originally used `name_field` to pass to that query,
#   but we prefer `search_field`, since it contains the Solr field we'll be querying (in this case, almost always `deduplication_key_ssi`).
Bulkrax::ValkyrieObjectFactory.class_eval do
  ##
  # @param value [String]
  # @param klass [Class, #where]
  # @param field [String, Symbol] A convenience parameter where we pass the
  #        same value to search_field.
  # @param name_field [String] the ActiveFedora::Base property name
  #        (e.g. "title")
  # @return [NilClass] when no object is found.
  # @return [Valkyrie::Resource] when a match is found, an instance of given
  #         :klass
  # rubocop:disable Metrics/ParameterLists
  def self.search_by_property(value:, klass:, field: nil, search_field: nil, **)
    search_field ||= field
    raise "Expected search_field or field got nil" if search_field.blank?
    return if value.blank?
    # Return nil or a single object.
    Hyrax.query_service.custom_queries.find_by_model_and_property_value(model: klass, property: search_field, value:)
  end
  # rubocop:enable Metrics/ParameterLists
end

# Hyrax v5.0.1 Override - since Bulkrax introduces the Wings constant when it installs, the first test to determine query type passes,
#   but the `is_a?` method produces an error because `Wings::Valkyrie` constant doesn't exist. This provides that test, as well.
Rails.application.config.to_prepare do
  Hyrax::DownloadsController.class_eval do
    def file_set_parent(file_set_id)
      file_set = if defined?(Wings) && defined?(Wings::Valkyrie) && Hyrax.metadata_adapter.is_a?(Wings::Valkyrie::MetadataAdapter)
                   Hyrax.query_service.find_by_alternate_identifier(alternate_identifier: file_set_id, use_valkyrie: Hyrax.config.use_valkyrie?)
                 else
                   Hyrax.query_service.find_by(id: file_set_id)
                 end
      @parent ||=
        case file_set
        when Hyrax::Resource
          Hyrax.query_service.find_parents(resource: file_set).first
        else
          file_set.parent
        end
    end
  end
end
