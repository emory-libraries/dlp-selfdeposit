#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative 'mods_metadata_to_csv_extractor'

if ARGV.empty?
  puts "Exiting -- This script must be in the following format:"
  puts "./dlp-selfdeposit/lib/metadata/extract_mods_metadata_to_csv.rb <full path to the CSV file produced by the migrate_fedora3_objects.rb script>"
  puts "<optional: full local path to the location that houses each folder containing files relevant to each PID>"
  exit 1
end

csv_path = ARGV[0]
local_folder_path = ARGV[1]

local_folder_path.nil? ? ModsMetadataToCsvExtractor.new(csv_path:).run : ModsMetadataToCsvExtractor.new(csv_path:, local_folder_path:).run
