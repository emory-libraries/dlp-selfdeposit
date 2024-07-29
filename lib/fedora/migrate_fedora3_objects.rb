#!/usr/bin/env ruby
# frozen_string_literal: true
require_relative 'migrate_fedora_three_objects'

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
