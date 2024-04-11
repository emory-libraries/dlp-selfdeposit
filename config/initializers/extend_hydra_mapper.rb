# frozen_string_literal: true
require 'hydra/works'

module Hydra::Works::Characterization
  class << self
    alias original_mapper_defaults mapper_defaults
    def mapper_defaults
      custom_mappings = {
        file_path: :file_path,
        creating_application_name: :creating_application_name,
        creating_os: :creating_os,
        puid: :puid
      }

      original_defaults.merge(custom_mappings)
    end
  end
end
