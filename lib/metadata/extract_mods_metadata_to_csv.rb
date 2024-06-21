#!/usr/bin/env ruby
# frozen_string_literal: true
require 'fileutils'
require 'nokogiri'
require 'open-uri'
require 'csv'
require 'pry'

class ExtractModsMetadataToCsv
  MULTIPLE_VALUE_PROCESSOR = ->(el) { el.children.map(&:text).join('|') }
  SINGLE_VALUE_PROCESSOR = ->(el) { el&.children&.first&.text }
  METADATA_FIELDS_LEGEND = {
    title: { xpath: '/mods:mods/mods:titleInfo/mods:title', processor: MULTIPLE_VALUE_PROCESSOR, ext_method: nil },
    holding_repository: { xpath: nil, processor: nil, ext_method: 'holding_repository_value' },
    emory_content_type: { xpath: '//mods:typeOfResource', processor: SINGLE_VALUE_PROCESSOR, ext_method: nil },
    content_genres: { xpath: '//mods:genre[@authority="marcgt"]', processor: SINGLE_VALUE_PROCESSOR, ext_method: nil },
    creator: { xpath: nil, processor: nil, ext_method: 'creator_values' },
    abstract: { xpath: '//mods:abstract', processor: MULTIPLE_VALUE_PROCESSOR, ext_method: nil },
    date_issued: { xpath: '/mods:mods/mods:originInfo/mods:dateIssued', processor: SINGLE_VALUE_PROCESSOR, ext_method: nil },
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
    research_categories: { xpath: '/mods:mods/mods:subject[@authority="proquestresearchfield"]/mods:topic', processor: MULTIPLE_VALUE_PROCESSOR, ext_method: nil }
  }.freeze

  def initialize(xml_path:, desired_csv_filename: 'mods_parsed_metadata.csv')
    @xml_path = xml_path
    @desired_csv_filename = desired_csv_filename
  end

  def run
    @mods_xml = pull_mods_xml
    @ret_hash = {}

    assign_values_to_ret_hash
    create_csv_from_ret_hash
  end

  private

  def pull_mods_xml
    file = File.open(@xml_path)
    Nokogiri::XML(file)
  end

  def assign_values_to_ret_hash
    METADATA_FIELDS_LEGEND.keys.each do |k|
      @ret_hash[k.to_s] = if METADATA_FIELDS_LEGEND[k][:ext_method].nil?
                            el = @mods_xml.xpath(METADATA_FIELDS_LEGEND[k][:xpath])
                            METADATA_FIELDS_LEGEND[k][:processor].call(el)
                          else
                            send(METADATA_FIELDS_LEGEND[k][:ext_method])
                          end
    end
  end

  def create_csv_from_ret_hash
    CSV.open(@desired_csv_filename, "wb") do |csv|
      keys = @ret_hash.keys
      # header_row
      csv << keys
      csv << @ret_hash.values_at(*keys)
    end
  end

  def holding_repository_value
    'Emory University. Library'
  end

  def rights_statements_value
    'http://rightsstatements.org/vocab/InC/1.0/'
  end

  def creator_values
    first_name_values = @mods_xml.xpath('//mods:name[@type="personal"]/mods:namePart[@type="given"]').map { |v| v.text.strip }
    last_name_values = @mods_xml.xpath('//mods:name[@type="personal"]/mods:namePart[@type="family"]').map { |v| v.text.strip }
    affiliation_values = @mods_xml.xpath('//mods:name[@type="personal"]/mods:affiliation').map { |v| v.text.strip }

    first_name_values.each_with_index.map { |v, i| [v, last_name_values[i], affiliation_values[i]].compact.join(', ') }.join('|')
  end
end

if ARGV.empty?
  puts "Exiting -- This script must be in the following format:"
  puts "./dlp-selfdeposit/lib/metadata/extract_mods_metadata_to_csv.rb <full path to the MODS XML file> <optional: desired name of returned CSV file>"
  puts "NOTE: desired CSV filename must end with the .csv extension. example: my_desired_filename.csv"
  exit 1
end

xml_path = ARGV[0]
desired_csv_filename = ARGV[1]

desired_csv_filename.nil? ? ExtractModsMetadataToCsv.new(xml_path:).run : ExtractModsMetadataToCsv.new(xml_path:, desired_csv_filename:).run
