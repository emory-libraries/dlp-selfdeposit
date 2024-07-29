#!/usr/bin/env ruby
# frozen_string_literal: true
require 'fileutils'
require 'nokogiri'
require 'open-uri'
require 'csv'
require_relative 'fedora_three_objects_migration_methods'

class MigrateFedoraThreeObjects
  ::ALLOWED_TYPES = {
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

  include FedoraThreeObjectsMigrationMethods

  def initialize(pids:, fedora_three_path:, fedora_username:, fedora_password:)
    @pids = pids
    @fedora_three_path = fedora_three_path
    @fedora_username = fedora_username
    @fedora_password = fedora_password
    @pids_with_no_binaries = []
    @pids_with_filenames = {}
    @date_time_started = DateTime.now.strftime('%Y%m%dT%H%M')
  end

  def run
    pid_arr = @pids.include?('.csv') ? pull_pids_csv : @pids.split(',')

    pid_arr.each do |pid|
      @pid = pid
      @pid_xml = pull_pid_xml
      copy_files_to_folder
    end

    file_end_reports
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
