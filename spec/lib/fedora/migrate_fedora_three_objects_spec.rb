# frozen_string_literal: true

require 'rails_helper'
require './lib/fedora/migrate_fedora_three_objects'

RSpec.describe MigrateFedoraThreeObjects, :clean do
  let(:pids) { 'f82th' }
  let(:migrator) { described_class.new(pids:, fedora_three_path: nil, fedora_username: nil, fedora_password: nil) }
  let(:xml_no_binaries) { File.open(fixture_path + '/xml/emory_f82th.xml') }
  let(:xml_with_binaries) { File.open(fixture_path + '/xml/emory_td5xw.xml') }
  let(:datastreams) { Nokogiri::XML(xml_no_binaries).xpath('//foxml:datastream') }

  shared_examples 'tests for xml presence method calling' do
    it 'calls #test_for_xmls and #test_for_audit' do
      expect(migrator).to receive(:test_for_xmls)
      expect(migrator).to receive(:test_for_audit)

      migrator.send(:pid_lacks_binaries, datastreams)
    end
  end

  context '#pid_lacks_binaries' do
    it 'returns true when XML lacks binaries' do
      expect(migrator.send(:pid_lacks_binaries, datastreams)).to be_truthy
    end

    include_examples 'tests for xml presence method calling'

    describe 'when xml contains binaries' do
      let(:datastreams) { Nokogiri::XML(xml_with_binaries).xpath('//foxml:datastream') }

      it 'returns false' do
        expect(migrator.send(:pid_lacks_binaries, datastreams)).to be_falsey
      end

      include_examples 'tests for xml presence method calling'
    end
  end
end
