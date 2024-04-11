# frozen_string_literal: true
require 'rails_helper'
require 'hyrax/specs/shared_specs/hydra_works'

RSpec.describe FileSet do
  subject(:file_set) { described_class.new }

  # it_behaves_like 'a Hyrax::FileSet'

  describe '#human_readable_type' do
    it 'has a human readable type' do
      expect(file_set.human_readable_type).to eq 'File Set'
    end
  end

  describe "metadata" do
    let(:file_set) { described_class.new }
    it 'has properties from characterization metadata' do
      expect(file_set).to respond_to(:file_path)
      expect(file_set).to respond_to(:creating_application_name)
      expect(file_set).to respond_to(:creating_os)
      expect(file_set).to respond_to(:puid)
    end
  end
end
