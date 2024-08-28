# frozen_string_literal: true
require 'fileutils'
require 'nokogiri'
require 'open-uri'
require 'csv'
require_relative 'mods_metadata_extraction_methods'

class ModsMetadataToCsvExtractor
  ::MULTIPLE_VALUE_PROCESSOR = ->(el) { el.children.map(&:text).join('|') }
  ::SINGLE_VALUE_PROCESSOR = ->(el) { el&.children&.first&.text }
  ::METADATA_FIELDS_LEGEND = {
    title: { xpath: '/mods:mods/mods:titleInfo/mods:title', processor: MULTIPLE_VALUE_PROCESSOR, ext_method: nil },
    holding_repository: { xpath: nil, processor: nil, ext_method: 'holding_repository_value' },
    emory_content_type: { xpath: '//mods:typeOfResource', processor: ->(el) { el&.children&.first&.text&.capitalize }, ext_method: nil },
    content_genre: { xpath: '//mods:genre[@authority="marcgt"]', processor: SINGLE_VALUE_PROCESSOR, ext_method: nil },
    creator: { xpath: nil, processor: nil, ext_method: 'creator_values' },
    creator_last_first: { xpath: nil, processor: nil, ext_method: 'extract_creator_last_first' },
    abstract: { xpath: '//mods:abstract', processor: MULTIPLE_VALUE_PROCESSOR, ext_method: nil },
    date_issued: { xpath: '/mods:mods/mods:originInfo/mods:dateIssued', processor: SINGLE_VALUE_PROCESSOR, ext_method: nil },
    date_issued_year: { xpath: '/mods:mods/mods:originInfo/mods:dateIssued', processor: nil, ext_method: 'extract_date_issued_year' },
    keyword: { xpath: '/mods:mods/mods:subject[@authority="keywords"]/mods:topic', processor: MULTIPLE_VALUE_PROCESSOR, ext_method: nil },
    parent_title: { xpath: '/mods:mods/mods:relatedItem[@type="host"]/mods:titleInfo/mods:title', processor: SINGLE_VALUE_PROCESSOR, ext_method: nil },
    publisher: { xpath: '/mods:mods/mods:relatedItem[@type="host"]/mods:originInfo/mods:publisher', processor: MULTIPLE_VALUE_PROCESSOR, ext_method: nil },
    final_published_versions: { xpath: '/mods:mods/mods:relatedItem[@displayLabel="Final Published Version"]/mods:identifier[@type="uri"]', processor: MULTIPLE_VALUE_PROCESSOR, ext_method: nil },
    issue: { xpath: '/mods:mods/mods:relatedItem[@type="host"]/mods:part/mods:detail[@type="number"]/mods:number', processor: SINGLE_VALUE_PROCESSOR, ext_method: nil },
    page_range_start: { xpath: '//mods:extent[@unit="pages"]/mods:start', processor: SINGLE_VALUE_PROCESSOR, ext_method: nil },
    page_range_end: { xpath: '//mods:extent[@unit="pages"]/mods:end', processor: SINGLE_VALUE_PROCESSOR, ext_method: nil },
    volume: { xpath: '/mods:mods/mods:relatedItem[@type="host"]/mods:part/mods:detail[@type="volume"]/mods:number', processor: SINGLE_VALUE_PROCESSOR, ext_method: nil },
    edition: { xpath: '//mods:edition', processor: SINGLE_VALUE_PROCESSOR, ext_method: nil },
    place_of_production: { xpath: '/mods:mods/mods:originInfo/mods:place/mods:placeTerm', processor: SINGLE_VALUE_PROCESSOR, ext_method: nil },
    issn: { xpath: '/mods:mods/mods:relatedItem[@type="host"]/mods:identifier[@type="issn"]', processor: SINGLE_VALUE_PROCESSOR, ext_method: nil },
    conference_name: { xpath: '//mods:relatedItem[@type="host"]/mods:name[@type="conference"]/mods:namePart', processor: SINGLE_VALUE_PROCESSOR, ext_method: nil },
    author_notes: { xpath: '/mods:mods/mods:note[@type="author notes"]', processor: SINGLE_VALUE_PROCESSOR, ext_method: nil },
    rights_statements: { xpath: nil, processor: nil, ext_method: 'rights_statements_value' },
    emory_ark: { xpath: '/mods:mods/mods:identifier[@type="ark"]', processor: MULTIPLE_VALUE_PROCESSOR, ext_method: nil },
    research_categories: { xpath: '/mods:mods/mods:subject[@authority="proquestresearchfield"]/mods:topic', processor: MULTIPLE_VALUE_PROCESSOR, ext_method: nil },
    rights_notes: { xpath: '/mods:mods/mods:accessCondition[@displayLabel="copyright"]', processor: MULTIPLE_VALUE_PROCESSOR, ext_method: nil },
    publisher_version: { xpath: nil, processor: nil, ext_method: 'publisher_version_value' },
    language: { xpath: '/mods:mods/mods:language/mods:languageTerm[@type="text"]', processor: MULTIPLE_VALUE_PROCESSOR, ext_method: nil },
    related_datasets: { xpath: '/mods:mods/mods:relatedItem[@type="references"]/@*[namespace-uri()="http://www.w3.org/1999/xlink" and local-name()="href"]',
                        processor: MULTIPLE_VALUE_PROCESSOR,
                        ext_method: nil },
    license: { xpath: '/mods:mods/mods:accessCondition/@*[namespace-uri()="http://www.w3.org/1999/xlink" and local-name()="href"]', processor: SINGLE_VALUE_PROCESSOR, ext_method: nil },
    grant_information: { xpath: '//mods:name[mods:role/mods:roleTerm="funder"]/mods:namePart', processor: MULTIPLE_VALUE_PROCESSOR, ext_method: nil },
    internal_rights_note: { xpath: nil, processor: nil, ext_method: 'internal_rights_note_value' }
  }.freeze

  include ::ModsMetadataExtractionMethods

  def initialize(csv_path:, local_folder_path: nil)
    @csv_path = csv_path
    @local_folder_path = local_folder_path
    @date_time_started = DateTime.now.strftime('%Y%m%dT%H%M')
  end

  def run
    @pids_and_filenames = pull_pids_and_filenames
    @ret_array_of_hashes = []

    @pids_and_filenames.keys.each do |pid|
      @pid = pid
      @mods_xml = pull_mods_xml
      @ret_hash = {}

      assign_values_to_ret_hash
      @ret_array_of_hashes << @ret_hash
    end

    create_csv_from_ret_hash_array
  end
end
