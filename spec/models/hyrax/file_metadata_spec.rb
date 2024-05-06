# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Hyrax::FileMetadata do
  subject(:file_metadata) { described_class.new }

  ["original_checksum", "file_path", "puid", "creating_application_name",
   "creating_os"].each do |attr|
    include_examples('checks model for new attribute response', attr)
  end
end
