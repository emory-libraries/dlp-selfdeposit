# frozen_string_literal: true

# Generated via
#  `rails generate hyrax:collection_resource CollectionResource`
require 'rails_helper'
require 'hyrax/specs/shared_specs/hydra_works'

RSpec.describe CollectionResource do
  subject(:collection) { described_class.new }

  it_behaves_like 'a Hyrax::PcdmCollection'
  it_behaves_like 'a model with basic metadata'

  ["administrative_unit", "contact_information", "notes", "holding_repository",
   "institution", "internal_rights_note", "system_of_record_ID", "emory_ark",
   "staff_notes"].each do |attr|
    include_examples('checks model for new attribute response', attr)
  end
end
