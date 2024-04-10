# frozen_string_literal: true

# Generated via
#  `rails generate hyrax:work_resource CollectionResource`
require 'rails_helper'
require 'valkyrie/specs/shared_specs'

RSpec.describe SelfDeposit::Forms::FileSetForm do
  let(:change_set) { described_class.new(resource) }
  let(:resource)   { ::FileSet.new }

  it_behaves_like 'a Valkyrie::ChangeSet'

  it('contains file_set_use as an expected field') { expect(change_set.fields.keys).to include('file_set_use') }
end
