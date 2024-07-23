# frozen_string_literal: true
require 'rails_helper'
require 'hyrax/specs/shared_specs/factories/administrative_sets'
require 'hyrax/specs/shared_specs/factories/permission_templates'
require 'hyrax/specs/shared_specs/factories/workflows'
require './lib/preservation_events'
include PreservationEvents
include Warden::Test::Helpers

RSpec.describe "viewing a publication show page", :clean_repo, :perform_enqueued, type: :feature do
  let!(:user) { FactoryBot.create(:user) }
  let(:admin_set) { FactoryBot.valkyrie_create(:hyrax_admin_set) }
  let(:permission_template) { FactoryBot.create(:permission_template, source_id: admin_set.id) }
  let!(:workflow) { FactoryBot.create(:workflow, allows_access_grant: true, active: true, permission_template_id: permission_template.id) }
  let!(:publication) do
    FactoryBot.valkyrie_create(:publication,
                               :public,
                               admin_set_id: admin_set.id,
                               depositor: user.user_key,
                               title: ['Al Pacino: A Life'],
                               creator: ['Pacino, Al, Emory University'],
                               date_issued_year: '1975',
                               parent_title: 'Father',
                               content_genre: 'Book',
                               emory_content_type: 'http://id.loc.gov/vocabulary/resourceTypes/txt',
                               publisher_version: 'Author Accepted Manuscript (After Peer Review)',
                               keyword: ['Godfather', 'Scent of a Woman', ""])
  end
  let(:preservation_events) do
    { "details" => "Modification",
      "end" => "2024-07-08T22:11:37.535+00:00",
      "start" => "2024-07-08T22:11:34.964+00:00",
      "type" => "Object updated",
      "user" => "systemuser@example.com",
      "outcome" => "Success",
      "software_version" => "SelfDeposit v.1" }
  end

  before do
    allow_any_instance_of(SolrDocument).to receive(:preservation_events).and_return(preservation_events)
    create_preservation_event(publication, preservation_events)
    Hyrax.persister.save(resource: publication)
    Hyrax.index_adapter.save(resource: publication)
    login_as user
    visit hyrax_publication_path(publication)
  end

  it 'contains preservation event elements' do
    expect(page).to have_content('Modification')
    expect(page).to have_content('Object updated')
    expect(page).to have_content('systemuser@example.com')
    expect(page).to have_content('Success')
    expect(page).to have_content('SelfDeposit v.1')
  end

  it 'contains a table of Preservation Events' do
    expect(page).to have_css('h2.card-title', text: 'Preservation Events')
    expect(find_all('table#preservation-event-table tbody tr')).to be_present
  end
end
