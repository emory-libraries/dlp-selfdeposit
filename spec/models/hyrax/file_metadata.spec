# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Hyrax::FileMetadata do
  subject(:file_metadata) { described_class.new }

  describe '#file_path' do
    it { is_expected.to respond_to(:file_path) }
  end
  describe '#puid' do
    it { is_expected.to respond_to(:puid) }
  end
  describe '#creating_application_name' do
    it { is_expected.to respond_to(:creating_application_name) }
  end
end