# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Hyrax::FileMetadata do
  subject(:file_metadata) { described_class.new }

  describe '#original_checksum' do
    it { is_expected.to respond_to(:original_checksum) }
  end
end
