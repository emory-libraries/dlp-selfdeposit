# frozen_string_literal: true
# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#

every :day, at: '7:00 am' do
  rake "selfdeposit:assign_necessary_users_to_emory_mediated_deposit"
end

every :month do
  rake "selfdeposit:google_scholar:sitemap"
end

# Learn more: http://github.com/javan/whenever
