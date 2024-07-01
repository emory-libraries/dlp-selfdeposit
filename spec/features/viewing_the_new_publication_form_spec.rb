# frozen_string_literal: true
require 'rails_helper'
include Warden::Test::Helpers

RSpec.describe 'viewing the new Publication form', :clean_repo, type: :feature do
  let(:user) { FactoryBot.create(:user) }
  before do
    login_as user
    visit new_hyrax_publication_path
  end

  it 'contains our custom directive text' do
    ["Please provide a description of your publication so that it can be properly cited by others.",
     "Next, click on the Files tab when you are ready to upload your content.",
     "The Save Work menu will indicate when you have completed all required elements for your submission.",
     "Please refer to our Help page for more guidance."].each do |sentence|
      expect(page).to have_content(sentence)
    end
  end

  it 'contains the expected field labels' do
    field_labels = find_all('label.control-label').map(&:text)
    expected_labels = [
      "Content genre required", "Title required", "First Name required", "Last Name required", "Institution required",
      "ORCID ID", "Primary Language required", "Date issued required", "Publisher required", "Publication Version",
      "Rights notes required", "License", "Final published versions", "Parent title", "Conference name", "Issn", "Isbn",
      "Series title", "Edition", "Volume", "Issue", "Page range start", "Page range end", "Place of production", "Sponsor",
      "Grant agencies", "Grant information", "Related datasets", "Abstract", "Author notes", "Keyword", "Subject",
      "Research categories", "Rights statement required", "Emory ark", "Internal rights note", "Staff notes", "System of record id",
      "Format required", "Library required", "Institution", "Data classification required", "Deduplication key", "Restricted to",
      "then open it up to"
    ]

    expect(field_labels).to match_array(expected_labels)
  end

  it 'does not contain the Relationships link when normal user' do
    expect(page).not_to have_link('Relationships', class: 'nav-link')
  end

  context 'when admin logged in' do
    before do
      # the below code adds the admin role to user
      user.roles << Role.find_or_create_by(name: Hyrax.config.admin_user_group_name)
      user.save
      visit new_hyrax_publication_path
    end

    it 'contains the Relationships link' do
      expect(page).to have_link('Relationships', class: 'nav-link')
    end
  end
end
