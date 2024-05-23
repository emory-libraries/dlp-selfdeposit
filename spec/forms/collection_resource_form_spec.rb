# frozen_string_literal: true

# Generated via
#  `rails generate hyrax:work_resource CollectionResource`
require 'rails_helper'
require 'valkyrie/specs/shared_specs'

RSpec.describe CollectionResourceForm do
  let(:change_set) { described_class.new(resource) }
  let(:resource)   { CollectionResource.new }

  it_behaves_like 'a Valkyrie::ChangeSet'

  it 'has the expected fields' do
    expect(change_set.fields.keys).to(
      include(
        "administrative_unit", "contact_information", "notes", "holding_repository",
        "institution", "internal_rights_note", "system_of_record_ID", "emory_ark",
        "staff_notes", "description", "subject_geo", "subject_names"
      )
    )
  end

  it 'lacks the unnecessary fields' do
    expect(change_set.primary_terms + change_set.secondary_terms).not_to(
      include(
        'rights_statement', 'target_audience', 'department', 'access_right', 'alternative_title',
        'arkivo_checksum', 'abstract', 'identifier', 'publisher', 'label', 'language', 'license',
        'related_url', 'resource_type', 'source', 'course'
      )
    )
  end
end
