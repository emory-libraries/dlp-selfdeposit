# frozen_string_literal: true
require 'rails_helper'
require 'hyrax/specs/shared_specs/hydra_works'

RSpec.describe Collection do
  subject(:collection) { described_class.new }

  # TODO: This is temporarily reverting Collection to an ActiveFedora::Base object
  #       so the application will load.
  # it_behaves_like 'a Hyrax::PcdmCollection'

  describe '#human_readable_type' do
    it 'has a human readable type' do
      expect(collection.human_readable_type).to eq 'Collection'
    end
  end

  ["administrative_unit", "contact_information", "notes", "holding_repository",
   "institution", "internal_rights_note", "system_of_record_ID", "emory_ark",
   "staff_notes", "description", "subject_geo", "subject_names"].each do |attr|
    include_examples('checks model for new attribute response', attr)
  end
end
