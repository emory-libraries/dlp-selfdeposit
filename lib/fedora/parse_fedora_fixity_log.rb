#!/usr/bin/env ruby
# frozen_string_literal: true
require 'fileutils'
require 'open-uri'
require 'csv'

if ARGV.empty?
  puts "Exiting -- This script must be in the following format:"
  puts "./dlp-selfdeposit/lib/fedora/parse_fedora_fixity_log.rb <full path to the fixity log provided by Fedora>"
  exit 1
end

fixity_log = ARGV[0]

document = File.open(fixity_log).read
outcomes = document.scan(/(?<=\<premis\:hasEventOutcome\>).*?(?=<\/premis\:hasEventOutcome\>)/)
number_of_outcomes = outcomes.count
counts_of_outcomes = outcomes.tally

::CSV.open("./fedora_fixity_report_#{DateTime.now.strftime('%Y%m%dT%H%M')}.csv", 'wb') do |csv|
  csv << ['Total Items Checked', 'Total Items Passed', 'Total Items Failed']
  csv << [number_of_outcomes, counts_of_outcomes["SUCCESS"], number_of_outcomes - counts_of_outcomes["SUCCESS"]]
end

puts "Report delivered to the same folder this was ran in."
