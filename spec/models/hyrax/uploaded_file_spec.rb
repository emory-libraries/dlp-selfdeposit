# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Hyrax::UploadedFile do
  let(:file1) { File.open(fixture_path + '/world.png') }

  subject { described_class.create(file: file1) }

  shared_examples 'tests for new attribute' do |attr|
    it "responds to our new attribute: #{attr}" do
      expect(subject).to respond_to(attr.to_sym)
    end
  end

  it "is not in the public directory" do
    temp_dir = Rails.root + 'tmp'
    expect(subject.file.path).to start_with temp_dir.to_s
  end

  ['fileset_name', 'fileset_use', 'desired_visibility'].each do |attr|
    include_examples 'tests for new attribute', attr
  end
end
