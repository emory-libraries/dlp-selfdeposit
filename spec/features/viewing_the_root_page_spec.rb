# frozen_string_literal: true
require 'rails_helper'
require 'hyrax/specs/shared_specs/factories/administrative_sets'
include Warden::Test::Helpers

RSpec.describe 'viewing the root page', :clean_repo, type: :feature do
  before { visit root_path }

  it('has the welcome text') { expect(page).to have_content('Emory Libraries') }

  context 'headers and meta tags' do
    let(:content) do
      'OpenEmory is an open access repository of scholarly works by Emory researchers and a service of Emory Libraries.'
    end

    it 'contains the expected meta tag' do
      expect(page).to have_css "meta[name='description'][content='#{content}']", visible: false
    end
  end

  context 'statistics' do
    let(:user) { FactoryBot.create(:user) }
    let(:admin_set) { FactoryBot.valkyrie_create(:hyrax_admin_set) }
    let(:publication) do
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

    it 'reports 1 work deposited' do
      Hyrax.index_adapter.wipe!
      publication
      visit root_path

      expect(page).to have_css('#total-works-num', text: '1')
    end

    it 'lacks unwanted dlp-stat columns' do
      expect(page).not_to have_css('.dlp-stat top', text: 'Downloads this year')
      expect(page).not_to have_css('.dlp-stat top', text: 'Total Downloads')
    end
  end
end
