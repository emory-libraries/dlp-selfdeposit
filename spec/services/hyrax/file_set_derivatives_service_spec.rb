# frozen_string_literal: true
# [Hyrax-overwrite-v5.0.1] This is a direct copy of the Hyrax test with an added test on L#57-70.
require 'rails_helper'
require 'hyrax/specs/shared_specs'
require 'hyrax/specs/shared_specs/factories/hyrax_file_metadata.rb'

RSpec.describe Hyrax::FileSetDerivativesService do
  context 'for a valkyrie resource', valkyrie_adapter: :test_adapter do
    let(:valid_file_set) do
      FactoryBot.valkyrie_create(:hyrax_file_metadata, :image)
    end

    it_behaves_like "a Hyrax::DerivativeService"

    it "can get derivative mime type arrays" do
      expect(Hyrax.config.derivative_mime_type_mappings.values.map(&:class).uniq).to contain_exactly(Array)
    end

    describe "#create_derivatives" do
      context "when given an audio file" do
        let(:valid_file_set) do
          FactoryBot.valkyrie_create(:hyrax_file_metadata, :audio_file, file_set_id: SecureRandom.uuid)
        end

        it "passes a mime-type and container to the audio derivatives service" do
          allow(Hydra::Derivatives::AudioDerivatives).to receive(:create)
          described_class.new(valid_file_set).create_derivatives('foo')
          expect(Hydra::Derivatives::AudioDerivatives).to have_received(:create).with(
            'foo',
            outputs: contain_exactly(
              hash_including(mime_type: 'audio/mpeg', container: 'service_file'),
              hash_including(mime_type: 'audio/ogg', container: 'service_file')
            )
          )
        end
      end

      context "when given a video file" do
        let(:valid_file_set) do
          FactoryBot.valkyrie_create(:hyrax_file_metadata, :video_file, file_set_id: SecureRandom.uuid)
        end

        it "passes a mime-type to the video derivatives service" do
          allow(Hydra::Derivatives::VideoDerivatives).to receive(:create)
          described_class.new(valid_file_set).create_derivatives('foo')
          expect(Hydra::Derivatives::VideoDerivatives).to have_received(:create).with(
            'foo',
            outputs: contain_exactly(
              hash_including(mime_type: 'video/mp4', container: 'service_file'),
              hash_including(mime_type: 'video/webm', container: 'service_file'),
              hash_including(mime_type: 'image/jpeg')
            )
          )
        end
      end

      context "when given an odt file" do
        let(:valid_file_set) do
          FactoryBot.valkyrie_create(
            :hyrax_file_metadata, mime_type: 'application/vnd.oasis.opendocument.text', file_set_id: SecureRandom.uuid
          )
        end

        it "does not pass this mime-type to the office document derivatives service" do
          allow(Hydra::Derivatives::DocumentDerivatives).to receive(:create)
          described_class.new(valid_file_set).create_derivatives('foo')
          expect(Hydra::Derivatives::DocumentDerivatives).not_to have_received(:create).with('foo')
        end
      end
    end
  end
end
