# frozen_string_literal: true
require './lib/preservation_event_model_methods'

# Generated by hyrax:models:install
class FileSet < Hyrax::FileSet
  include Hyrax::Schema(:emory_file_set_metadata)
  include PreservationEventModelMethods
end
