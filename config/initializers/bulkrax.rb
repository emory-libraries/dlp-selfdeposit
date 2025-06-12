# frozen_string_literal: true
require './lib/preservation_events'

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
      "author_notes" => { from: ["author_notes"] },
      "conference_name" => { from: ["conference_name"] },
      "content_genre" => { from: ["content_genre"] },
      "creator" => { from: ["creator"], split: '\|', join: '|' },
      "creator_last_first" => { from: ["creator_last_first"], split: '\|', join: '|' },
      "data_classification" => { from: ["data_classification"] },
      "date_issued" => { from: ["date_issued"] },
      "date_issue_year" => { from: ["date_issued_year"] },
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
      "publisher" => { from: ["publisher"] },
      "publisher_version" => { from: ["publisher_version"] },
      "related_datasets" => { from: ["related_datasets"], split: '\|', join: '|' },
      "research_categories" => { from: ["research_categories"], split: '\|', join: '|' },
      "rights_notes" => { from: ["rights_notes"], split: '\|', join: '|' },
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

# Bulkrax v8.1.0 Override
Bulkrax::ValkyrieObjectFactory.class_eval do
  include ::PreservationEvents

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
  #
  # This method had a typo (custom_query instead of custom_queries). `find_by_model_and_property_value` as
  #   it currently exists in Bulkrax uses SQL, which makes it Postgres-only. It originally used `name_field` to pass to that query,
  #   but we prefer `search_field`, since it contains the Solr field we'll be querying (in this case, almost always `deduplication_key_ssi`).
  def self.search_by_property(value:, klass:, field: nil, search_field: nil, **)
    search_field ||= field
    raise "Expected search_field or field got nil" if search_field.blank?
    return if value.blank?
    # Return nil or a single object.
    Hyrax.query_service.custom_queries.find_by_model_and_property_value(model: klass, property: search_field, value:)
  end
  # rubocop:enable Metrics/ParameterLists

  # Overridden to include our custom method that alters the UploadFile objects with our FileSet metatdata passed into the CSV line items.
  def create_work(attrs)
    event_start = DateTime.current # record event_start timestamp
    attrs = HashWithIndifferentAccess.new(attrs)
    apply_emory_fileset_metatdata(attrs)
    # NOTE: We do not add relationships here; that is part of the create relationships job.
    perform_transaction_for(object:, attrs:) do
      uploaded_files, file_set_params = prep_fileset_content(attrs)
      transactions["change_set.create_work"]
        .with_step_args(
          'work_resource.add_file_sets' => { uploaded_files:, file_set_params: },
          "change_set.set_user_as_depositor" => { user: @user },
          "work_resource.change_depositor" => { user: @user },
          'work_resource.save_acl' => { permissions_params: [attrs.try('visibility') || 'open'].compact }
        )
    end

    process_work_creation_preservation_events(event_start)
  end

  # Overridden to include our custom method that alters the UploadFile objects with our FileSet metatdata passed into the CSV line items.
  def update_work(attrs)
    event_start = DateTime.current # record event_start timestamp
    attrs = HashWithIndifferentAccess.new(attrs)
    apply_emory_fileset_metatdata(attrs)
    perform_transaction_for(object:, attrs:) do
      uploaded_files, file_set_params = prep_fileset_content(attrs)
      transactions["change_set.update_work"]
        .with_step_args(
          'work_resource.add_file_sets' => { uploaded_files:, file_set_params: },
          'work_resource.save_acl' => { permissions_params: [attrs.try('visibility') || 'open'].compact }
        )
    end

    pulled_work = pull_publication_for_preservation_events

    create_preservation_event(pulled_work, work_update(event_start:, user_email: @user.email))
  end

  # A brand new function that assigns the values passed into the Publication CSV line to the ingested FileSets created from the line.
  def apply_emory_fileset_metatdata(attrs)
    importer = Bulkrax::Importer.find(Bulkrax::ImporterRun.find(@importer_run_id).importer_id)
    pertinent_entry = importer.entries.find { |e| e.raw_metadata['deduplication_key'] == attributes['deduplication_key'] }
    raise "No associated Entry was found" unless pertinent_entry
    uploaded_files, _file_set_params = prep_fileset_content(attrs)

    uploaded_files.each do |file|
      file.fileset_use = assign_fileset_use(supplementary_file(file.file_identifier))
      file.desired_visibility = assign_fileset_visibility(supplementary_file(file.file_identifier))
      file.fileset_name = assign_fileset_name(pertinent_entry, file.file_identifier)
      file.save
    end
  end

  def assign_fileset_use(supplementary_file)
    supplementary_file ? 'Supplemental Preservation' : 'Primary Content'
  end

  def assign_fileset_visibility(supplementary_file)
    supplementary_file ? 'restricted' : 'open'
  end

  def assign_fileset_name(entry, file_identifier)
    entry_pid = entry.raw_metadata['deduplication_key']
    return file_identifier if entry_pid.blank?

    supplementary_file(file_identifier) ? file_identifier : "Publication File - #{entry_pid}.#{file_identifier.split('.').last}"
  end

  def supplementary_file(file_name)
    !file_name.include?('content.')
  end

  ##
  # @!group Class Method Interface

  ##
  # @note This does not save either object.  We need to do that in another
  #       loop.  Why?  Because we might be adding many items to the parent.
  #
  # Bulkrax BUG: With newer ruby versions, shoveling (<<) to a variable set with an array produces a frozen array error.
  #   The += methods seems to work fine, though.
  def self.add_child_to_parent_work(parent:, child:)
    return true if parent.member_ids.include?(child.id)

    parent.member_ids += Array(child.id)
    parent.save
  end

  # Bulkrax BUG: With newer ruby versions, shoveling (<<) to a variable set with an array produces a frozen array error.
  #   The += methods seems to work fine, though.
  def self.add_resource_to_collection(collection:, resource:, user:)
    resource.member_of_collection_ids += Array(collection.id)
    save!(resource:, user:)
  end

  private

  def pull_publication_for_preservation_events
    Hyrax.custom_queries.find_publication_by_deduplication_key(deduplication_key: attributes['deduplication_key'])
  end

  def process_work_creation_preservation_events(event_start)
    pulled_work = pull_publication_for_preservation_events

    create_preservation_event(pulled_work, work_creation(event_start:, user_email: @user.email))
    create_preservation_event(pulled_work, work_policy(event_start:, visibility: pulled_work.visibility, user_email: @user.email))
  end
end

Rails.application.config.to_prepare do
  # [Hyrax-override-v5.1 (ec2c524)] since Bulkrax introduces the Wings constant when it installs, the first test to determine query type passes,
  #   but the `is_a?` method produces an error because `Wings::Valkyrie` constant doesn't exist. This provides that test, as well.
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

  Bulkrax::CsvParser.class_eval do
    # Bulkrax v8.1.0 Override - have to override following methods here because prior logic only looks in application folder
    #
    # `file_path`'s override: reduces Cyclomatic Complexity to abstract setting `file_mapping` and `locate_files_for_record`
    #   (our custom function) to separate methods.
    # Retrieve file paths for [:file] mapping in records
    #  and check all listed files exist.
    def file_paths
      raise StandardError, 'No records were found' if records.blank?
      return [] if importerexporter.metadata_only?

      @file_paths ||= records.map do |r|
        file_mapping = pull_file_mapping
        next if r[file_mapping].blank?

        locate_files_for_record(r[file_mapping].split(Bulkrax.multi_value_element_split_on), r[:deduplication_key])
      end.flatten.compact.uniq
    end

    # `pull_file_mapping` override: moved to it's own method for Cyclomatic Complexity reduction.
    def pull_file_mapping
      Bulkrax.field_mappings.dig(self.class.to_s, 'file', :from)&.first&.to_sym || :file
    end

    # `locate_files_for_record` override: refactored after we added our own EFS mount locating (L#289).
    def locate_files_for_record(file_names, pid)
      filenames_without_unwanted(file_names).map do |fn|
        file = if zip?
                 File.join(path_to_files, fn.tr(' ', '_'))
               else
                 File.join(path_to_files, "emory_#{pid}", fn.tr(' ', '_'))
               end
        if File.exist?(file) # rubocop:disable Style/GuardClause
          file
        else
          raise "File #{file} does not exist"
        end
      end
    end

    # `path_to_files` override: instead of using a import file location passed into the CSV or set in config,
    #   we hardcode the mounted EFS folder to locate files.
    # Retrieve the path where we expect to find the files
    def path_to_files(**args)
      filename = args.fetch(:filename, '')

      return @path_to_files if @path_to_files.present? && filename.blank?
      @path_to_files = File.join(
        zip? ? "#{importer_unzip_path}/files" : '/mnt/efs/current_batch'
      )
    end

    def filenames_without_unwanted(file_names)
      file_names.reject { |name| name == 'DC.xml' }
    end
  end

  Bulkrax::CsvEntry.class_eval do
    # `path_to_file` override: this adds in the extra path of the record's PID-related folder within the EFS mount.
    # If only filename is given, construct the path (/files/my_file)
    def path_to_file(file)
      # return if we already have the full file path
      return file if File.exist?(file)
      path = importerexporter.parser.path_to_files
      f = parser.zip? ? File.join(path, file) : File.join(path, "emory_#{@record['deduplication_key']}", file)
      return f if File.exist?(f)
      raise "File #{f} does not exist"
    end
  end
end
