# frozen_string_literal: true
require 'stackprof'
require 'rack-mini-profiler'

# initialization is skipped so trigger it
Rack::MiniProfilerRails.initialize!(Rails.application)
