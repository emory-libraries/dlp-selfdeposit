# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Hyrax::Characterization::ValkyrieCharacterizationService do
  describe "#transform_original_checksum" do
    let(:file) { "spec/fixtures/world.png" }
    let(:file_metadata) { instance_double(Hyrax::FileMetadata) }

    it 'produces three SHA digests' do
      terms = { format_label: ["JPEG File Interchange Format"],
                file_mime_type: ["image/jpeg"],
                exif_tool_version: ["12.50"],
                file_size: ["7812"],
                filename: ["49-thumbnail.jpeg20240411-2435-bzp0ef.jpeg"],
                original_checksum: ["f304c45f2102cdd5c83dd4b6bad3f388".dup],
                well_formed: ["true"],
                valid: ["true"],
                byte_order: ["big endian"],
                compression: ["JPEG"],
                width: ["145"],
                height: ["150"],
                color_space: ["BlackIsZero"] }.to_h
      allow(file_metadata).to receive_message_chain(:file, :io, :path).and_return(file)
      described_class.new(metadata: file_metadata, file:, **Hyrax.config.characterization_options).transform_original_checksum(terms)

      expect(terms[:original_checksum].size).to eq(3)
      ['urn:md5:', 'urn:sha256:', 'urn:sha1:'].each do |sub_str|
        expect(terms[:original_checksum].any? { |checksum| checksum.include? sub_str }).to be_truthy
      end
      expect(terms[:original_checksum]).to include('urn:md5:f304c45f2102cdd5c83dd4b6bad3f388')
    end
  end
end
