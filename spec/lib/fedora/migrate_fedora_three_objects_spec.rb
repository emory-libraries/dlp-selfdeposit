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

  context '#record_filenames_with_path' do
    it 'sets and concatenates filenames' do
      migrator.instance_variable_set(:@pid, pids)
      migrator.send(:record_filenames_with_path, 'bill.jpeg')
      migrator.send(:record_filenames_with_path, 'ted.png')
      migrator.send(:record_filenames_with_path, 'death.flac')

      expect(migrator.instance_variable_get(:@pids_with_filenames)).to eq({ pids => "bill.jpeg;ted.png;death.flac" })
    end
  end

  context '#truncate_long_filenames' do
    let(:long_filename) do
      'Prinz_2007_systematic-computational-exploration-of-the-parameter-space-of-the-multi-compartment-model-of-the-lobster-pyloric-pacemaker-' \
      'kernel-suggests-that-the-kernel-can-achieve-functional-activity-under-various-parameter-configurations.pdf'
    end
    let(:short_filename) { 'a_short_and_sweet_title.pdf' }

    it 'truncates filenames that are longer than 150 characters' do
      expect(migrator.send(:truncate_long_filenames, long_filename)).to eq(
        "Prinz_2007_systematic-computational-exploration-of-the-parameter-space-of-the-multi-compartment-modeTRUNCATED_FILE_NAME.pdf"
      )
    end

    it('returns the filename untouched if it is shorter than 150 characters') { expect(migrator.send(:truncate_long_filenames, short_filename)).to eq(short_filename) }
  end

  context '#process_binary_filename' do
    let(:datastreams) { Nokogiri::XML(xml_with_binaries).xpath('//foxml:datastream') }
    let(:no_label_datastream) { datastreams[7] }
    let(:label_datastream) { datastreams[4] }

    it 'uses the LABEL element if it is available' do
      allow(migrator).to receive(:truncate_long_filenames).and_call_original
      expect(migrator).to receive(:truncate_long_filenames)
      expect(label_datastream.elements.first['LABEL']).to eq(
        'Prinz_2007_systematic-computational-exploration-of-the-parameter-space-of-the-multi-compartment-model-of-the-lobster-pyloric-pacemaker-' \
        'kernel-suggests-that-the-kernel-can-achieve-functional-activity-under-various-parameter-configurations.pdf'
      )
      expect(migrator.send(:process_binary_filename, datastream: label_datastream)).to eq(
        "Prinz_2007_systematic-computational-exploration-of-the-parameter-space-of-the-multi-compartment-modeTRUNCATED_FILE_NAME.pdf"
      )
    end

    it 'creates a default filename if LABEL is not present' do
      expect(migrator).not_to receive(:truncate_long_filenames)
      expect(migrator.send(:process_binary_filename, datastream: no_label_datastream)).to eq("content.pdf")
    end
  end
end
