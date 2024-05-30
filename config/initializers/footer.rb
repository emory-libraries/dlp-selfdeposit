# frozen_string_literal: true

GIT_SHA =
  if Rails.env.production? && File.exist?('/opt/dlp-selfdeposit/revisions.log')
    `tail -1 /opt/dlp-selfdeposit/revisions.log`.chomp.split(" ")[3].gsub(/\)$/, '')&.first(7)
  elsif Rails.env.development? || Rails.env.test?
    `git rev-parse HEAD`.chomp&.first(7)
  end

BRANCH =
  if Rails.env.production? && File.exist?('/opt/dlp-selfdeposit/revisions.log')
    `tail -1 /opt/dlp-selfdeposit/revisions.log`.chomp.split(" ")[1]
  elsif Rails.env.development? || Rails.env.test?
    `git rev-parse --abbrev-ref HEAD`.chomp
  end

LAST_UPDATED =
  if Rails.env.production? && File.exist?('/opt/dlp-selfdeposit/revisions.log')
    deployed = `tail -1 /opt/dlp-selfdeposit/revisions.log`.chomp.split(" ")[7]
    Date.parse(deployed).strftime("%d %B %Y")
  elsif Rails.env.development? || Rails.env.test?
    # Use latest commit date instead of deployment date in development
    `git config --global --add safe.directory /app`
    date_str = `git log -1 --format=%cd`.chomp
    date = Date.strptime(date_str, '%a %b %d')
    date.strftime('%d %B %Y')
  end
