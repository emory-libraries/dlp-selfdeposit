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
    it('returns true when XML lacks binaries') { expect(migrator.send(:pid_lacks_binaries, datastreams)).to be_truthy }
    include_examples 'tests for xml presence method calling'

    describe 'when xml contains binaries' do
      let(:datastreams) { Nokogiri::XML(xml_with_binaries).xpath('//foxml:datastream') }

      it('returns false') { expect(migrator.send(:pid_lacks_binaries, datastreams)).to be_falsey }
      include_examples 'tests for xml presence method calling'
    end
  end

  context '#test_for_xmls' do
    let(:xml_datastreams) { datastreams.select { |ds| migrator.send(:test_for_xmls, datastream: ds) } }

    it 'returns true for all XML datastreams besides AUDIT' do
      expect(xml_datastreams.map { |ds| ds['ID'] }).not_to include('AUDIT')
      expect(xml_datastreams.map { |ds| ds.elements.first['MIMETYPE'] }.all? { |mt| mt.include?('xml') }).to be_truthy
    end
  end

  context '#test_for_audit' do
    let(:audit_datastream) { datastreams.find { |ds| migrator.send(:test_for_audit, datastream: ds) } }

    it('returns true when the datastream contains an ID of AUDIT') { expect(audit_datastream['ID']).to eq('AUDIT') }
  end
end
