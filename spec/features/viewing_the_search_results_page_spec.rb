# frozen_string_literal: true
require 'rails_helper'
require 'hyrax/specs/shared_specs/factories/administrative_sets'
require 'hyrax/specs/shared_specs/factories/permission_templates'
require 'hyrax/specs/shared_specs/factories/workflows'
include Warden::Test::Helpers

RSpec.describe "viewing the search results page", :clean_repo, :perform_enqueued, type: :feature do
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
                               creator_last_first: ['Pacino, Al'],
                               date_issued_year: '1975',
                               parent_title: 'Father',
                               content_genre: 'Book',
                               publisher_version: 'Author Accepted Manuscript (After Peer Review)',
                               keyword: ['Godfather', 'Scent of a Woman'])
  end
  let(:facets_pulled) { find_all('.facets-collapse .card') }

  before do
    Hyrax.index_adapter.wipe!
    Hyrax.index_adapter.save(resource: publication)
    visit search_catalog_path
  end

  context 'sidebar facets' do
    it 'contains the expected facet labels' do
      expect(facets_pulled.count).to eq(6)
      expect(facets_pulled.map { |f| f.find('h3 button').text }).to match_array(
        ["Author", "Date", "Journal or Parent Publication Title", "Type", "Publisher Version", 'Keyword']
      )
    end

    it 'contains the expected facet values' do
      card_contents = facets_pulled.map { |f| f.find_all('.facet-content .card-body .facet-values li') }.flatten

      expect(card_contents.count).to eq(7)
      expect(card_contents.map { |c| c.find('span .facet-select').text }).to match_array(
        ["Pacino, Al", "1975", "Father", "Book", "Author Accepted Manuscript (After Peer Review)", "Godfather", "Scent of a Woman"]
      )
    end
  end
end