# frozen_string_literal: true

# Generated via
#  `rails generate hyrax:collection_resource CollectionResource`
require 'rails_helper'
require 'hyrax/specs/shared_specs/hydra_works'

RSpec.describe CollectionResource do
  subject(:collection) { described_class.new }

  it_behaves_like 'a Hyrax::PcdmCollection'

  it 'has abstracts' do
    expect { collection.abstract = ['lorem ipsum', 'a story about moomins'] }
      .to change { collection.abstract }
      .to contain_exactly 'lorem ipsum', 'a story about moomins'
  end

  it 'has a label' do
    expect { collection.label = 'one single label' }
      .to change { collection.label }
      .to eq 'one single label'
  end

  it 'has licenses' do
    expect { collection.license = ['http://example.com/li1', 'http://example.com/li2'] }
      .to change { collection.license }
      .to contain_exactly 'http://example.com/li1', 'http://example.com/li2'
  end

  it 'has a relative path' do
    expect { collection.relative_path = 'hamburger' }
      .to change { collection.relative_path }
      .to eq 'hamburger'
  end

  it 'has resource types' do
    expect { collection.resource_type = ['book', 'image'] }
      .to change { collection.resource_type }
      .to contain_exactly 'book', 'image'
  end

  it 'has rights notes' do
    expect { collection.rights_notes = ['secret', 'do not use'] }
      .to change { collection.rights_notes }
      .to contain_exactly 'secret', 'do not use'
  end

  it 'has sources' do
    expect { collection.source = ['first', 'second'] }
      .to change { collection.source }
      .to contain_exactly 'first', 'second'
  end

  it 'has subjects' do
    expect { collection.subject = ['moomin', 'snork'] }
      .to change { collection.subject }
      .to contain_exactly 'moomin', 'snork'
  end

  it 'does not have language' do
    expect(collection).not_to respond_to(:language)
  end

  it 'does not have rights statements' do
    expect(collection).not_to respond_to(:rights_statement)
  end

  ["administrative_unit", "contact_information", "notes", "holding_repository",
   "institution", "internal_rights_note", "system_of_record_ID", "emory_ark",
   "staff_notes"].each do |attr|
    include_examples('checks model for new attribute response', attr)
  end
end
