# frozen_string_literal: true
require 'rails_helper'
require 'hyrax/specs/shared_specs/factories/administrative_sets'
require 'hyrax/specs/shared_specs/factories/permission_templates'
require 'hyrax/specs/shared_specs/factories/workflows'
include Warden::Test::Helpers

RSpec.describe "viewing a FileSet's show page", :clean_repo, :perform_enqueued, type: :feature do
  let!(:user) { FactoryBot.create(:user) }
  let(:admin_set) { FactoryBot.valkyrie_create(:hyrax_admin_set) }
  let(:permission_template) { FactoryBot.create(:permission_template, source_id: admin_set.id) }
  let!(:workflow) { FactoryBot.create(:workflow, allows_access_grant: true, active: true, permission_template_id: permission_template.id) }
  let!(:file_set) { FactoryBot.valkyrie_create(:hyrax_file_set, :with_files, title: ['Test File Set'], depositor: user.user_key, read_groups: ['public'], edit_users: [user]) }
  let!(:publication) { FactoryBot.valkyrie_create(:publication, admin_set_id: admin_set.id, depositor: user.user_key, members: [file_set]) }
  let(:preservation_events) do
    [{ "event_details" => ["urn:sha256:3f97a01efdd0ea847a24aecad6f4bfa8640838d393e35cc553408908ace0928e",
                           "urn:sha1:3ed1da08d5d0a400612216bc0134780d7495b54e",
                           "urn:md5:354c7b6da70b120e897c4df08e74e6ac"],
       "event_end" => "2024-07-08T22:11:37.535+00:00",
       "event_start" => "2024-07-08T22:11:34.964+00:00",
       "event_type" => "Message Digest Calculation",
       "initiating_user" => "systemuser@example.com",
       "outcome" => "Failure",
       "software_version" => "FITS Servlet v1.6.0, Fedora v6.5.0, Ruby Digest library" }.to_json]
  end

  before do
    publication
    allow_any_instance_of(SolrDocument).to receive(:file_path).and_return(['/path/to/image.png'])
    allow_any_instance_of(SolrDocument).to receive(:persistent_unique_identification).and_return(['fmt/12'])
    allow_any_instance_of(SolrDocument).to receive(:creating_application_name).and_return(['ImageMagick'])
    allow_any_instance_of(SolrDocument).to receive(:original_checksum).and_return(['urn:sha1:3ed1da08d5d0a400612216bc0134780d7495b54e',
                                                                                   'urn:md5:354c7b6da70b120e897c4df08e74e6ac',
                                                                                   'urn:sha256:3f97a01efdd0ea847a24aecad6f4bfa8640838d393e35cc553408908ace0928e'])
    allow_any_instance_of(SolrDocument).to receive(:creating_os).and_return(['MacOSX Sapphire'])
    allow_any_instance_of(SolrDocument).to receive(:preservation_events).and_return(preservation_events)
    login_as user
    visit hyrax_file_set_path(file_set)
  end

  it 'contains the custom characterization elements' do
    expect(page).to have_content('File Path: ')
    expect(page).to have_content('image.png') # once in File Path, once in Preservation Events
    expect(page).to have_content('Creating Application Name: ImageMagick')
    expect(page).to have_content('Creating Os: MacOSX Sapphire')
    expect(page).to have_content('Persistent Unique Identification: fmt/12')
    expect(page).to have_content('Original Checksum: ')
    expect(page).to have_content('urn:sha1:3ed1da08d5d0a400612216bc0134780d7495b54e')
    expect(page).to have_content('urn:md5:354c7b6da70b120e897c4df08e74e6ac')
    expect(page).to have_content('urn:sha256:3f97a01efdd0ea847a24aecad6f4bfa8640838d393e35cc553408908ace0928e')
  end

  it 'contains a table of Preservation Events' do
    expect(page).to have_css('h2.fs-preservation-events-header', text: 'Preservation Events')
    expect(find_all('table#fs-preservation-event-table tbody tr')).to be_present
  end
end
