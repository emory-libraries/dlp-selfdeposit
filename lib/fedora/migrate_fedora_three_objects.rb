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
    rescue Nokogiri::XML::XPath::SyntaxError
      @pids_with_no_binaries += [@pid]
      puts "PID emory:#{pid} lacked a datastream XML structure."
    end

    file_end_reports
  end
end
