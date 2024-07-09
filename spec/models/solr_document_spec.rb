# frozen_string_literal: true
require 'rails_helper'

RSpec.describe ::SolrDocument, type: :model do
  subject(:document) { described_class.new(attributes) }
  let(:attributes) { {} }

  shared_examples('tests for a direct solr index value return') do |method_name, solr_field, val|
    describe "##{method_name}" do
      let(:attributes) { { "#{solr_field}": [val] } }

      it 'returns the value from the solr document index' do
        expect(document.send(method_name)).to eq attributes[solr_field.to_sym]
      end
    end
  end

  include_examples('tests for a direct solr index value return',
                   'file_path',
                   'file_path_ssim',
                   '/usr/local/tomcat/webapps/fits/upload/1720036857165/halloween-kills.jpeg20240703-1-ed8o7o.jpeg')
  include_examples('tests for a direct solr index value return',
                   'creating_application_name',
                   'creating_application_name_ssim',
                   'ImageMagick')
  include_examples('tests for a direct solr index value return',
                   'creating_os',
                   'creating_os_ssim',
                   'MacOSX Sapphire')
  include_examples('tests for a direct solr index value return',
                   'persistent_unique_identification',
                   'puid_ssim',
                   'fmt/43')
  include_examples('tests for a direct solr index value return',
                   'original_checksum',
                   'original_checksum_ssim',
                   ["urn:sha1:8494cfb8d05e02b79ab6df1afe7545386a74bf39",
                    "urn:sha256:16b97ef201fa90417ff54157f67e180bcf7d2052cd55ced649d1cc20cddd22c9",
                    "urn:md5:9a553c8259a8ccfa80225dda33d7bf25"])
  include_examples('tests for a direct solr index value return',
                   'preservation_events',
                   'preservation_events_tesim',
                   '{\"event_details\":\"Visibility/access controls assigned: Emory Network\",\"event_end\":' \
                     '\"2024-07-08T15:36:11.455+00:00\",\"event_start\":\"2024-07-07T15:46:11.455+00:00\",\"event_type\":' \
                     '\"Policy Assignment\",\"initiating_user\":\"admin@example.com\",\"outcome\":\"Success\",' \
                     '\"software_version\":\"SelfDeposit 1.0\"}')
end
