#!/usr/bin/env ruby
# frozen_string_literal: true
require 'fileutils'
require 'nokogiri'
require 'open-uri'

class MigrateFedoraThreeObjects
  ALLOWED_TYPES = {
    'application/pdf': 'pdf',
    'application/vnd.openxmlformats-officedocument.wordprocessingml.document': 'docx',
    'application/msword': 'doc',
    'application/vnd.openxmlformats-officedocument.presentationml.presentation': 'pptx',
    'application/vnd.ms-powerpoint': 'ppt',
    'image/jpeg': 'jpeg',
    'image/tiff': 'tiff',
    'image/png': 'png',
    'application/vnd.ms-excel': 'xls',
    'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet': 'xlsx'
  }.freeze

  def initialize(pids:, fedora_three_path:, fedora_username:, fedora_password:)
    @pids = pids
    @fedora_three_path = fedora_three_path
    @fedora_username = fedora_username
    @fedora_password = fedora_password
  end

  def run
    pid_arr = @pids.split(',')

    pid_arr.each do |pid|
      @pid = pid
      make_pid_folder
      @pid_xml = pull_pid_xml
      copy_files_to_folder
    end
  end

  private

  def make_pid_folder
    FileUtils.mkdir_p "emory_#{@pid}"
  end

  def pull_pid_xml
    system('fedora-export.sh', @fedora_three_path.split('://').last, @fedora_username, @fedora_password,
           "emory:#{@pid}", 'info:fedora/fedora-system:FOXML-1.1', 'migrate', '.', @fedora_three_path.split('://').first)
    file = File.open("./emory_#{@pid}.xml")
    Nokogiri::XML(file)
  end

  def copy_files_to_folder
    datastreams = @pid_xml.xpath('//foxml:datastream')
    @content_index = 0

    datastreams.each do |datastream|
      if datastream['ID'] == 'AUDIT'
        pull_audit_object(datastream:)
      elsif test_for_xmls(datastream:)
        pull_xml_object(datastream:)
      else
        pull_binary_object(datastream:)
      end
    end
  end

  def test_for_xmls(datastream:)
    datastream['ID'] != 'AUDIT' && ['text/xml', 'application/rdf+xml'].include?(datastream.elements.first['MIMETYPE'])
  end

  def pull_audit_object(datastream:)
    IO.copy_stream(StringIO.new(datastream.at_xpath('//foxml:datastreamVersion/foxml:xmlContent').to_s), "./emory_#{@pid}/AUDIT.xml")
  end

  def pull_xml_object(datastream:)
    xml_doc = datastream['ID']
    download = URI.open("#{@fedora_three_path}/fedora/get/emory:#{@pid}/#{xml_doc}")

    IO.copy_stream(download, "./emory_#{@pid}/#{download.base_uri.to_s.split('/')[-1]}.xml")
  end

  def pull_binary_object(datastream:)
    binary_id = datastream['ID']
    binary_filename = datastream.elements.first['LABEL']
    blank_filename_test = binary_filename.empty? || binary_filename.include?('/')
    binary_ext = ALLOWED_TYPES[:"#{datastream.elements.first['MIMETYPE']}"]
    binary_save_name = blank_filename_test ? ["content_#{@pid}_#{@content_index}", binary_ext].join('.') : binary_filename
    download = URI.open("#{@fedora_three_path}/fedora/get/emory:#{@pid}/#{binary_id}")

    @content_index += 1 if blank_filename_test
    IO.copy_stream(download, "./emory_#{@pid}/#{binary_save_name}")
  end
end

if ARGV.length != 4
  puts "Exiting -- This script must be in the following format:"
  puts "./lib/fedora/migrate_fedora3_objects.rb <a list of pids separated by commas> <Fedora 3 path> <Fedora 3 username> <Fedora 3 password>"
  puts "NOTES: pids must be entered without the 'emory:' substring and the Fedora path must follow the following format:"
  puts "http://example.com:1234"
  exit 1
end

pids = ARGV[0]
fedora_three_path = ARGV[1]
fedora_username = ARGV[2]
fedora_password = ARGV[3]

MigrateFedoraThreeObjects.new(pids:, fedora_three_path:, fedora_username:, fedora_password:).run
