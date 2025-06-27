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
      "Type of Material required", "Title required", "First Name required", "Last Name required", "Institution required",
      "ORCID ID", "Primary Language required", "Date required", "Publisher required", "Publication Version",
      "Copyright Statement required", "License", "Final Published Version (URL)", "Title of Journal or Parent Work",
      "Conference or Event Name", "ISSN", "ISBN", "Series Title", "Edition", "Volume", "Issue", "Start Page",
      "End Page", "Place of Publication or Presentation", "Grant/Funding Agency", "Grant/Funding Information", "Authors",
      "Supplemental Material (URL)", "Abstract", "Author Notes", "Keywords", "Subject - Topics", "Research Categories",
      "Copyright Status required", "Emory ark", "Internal rights note", "Staff notes", "System of record id", "Format required",
      "Library required", "Institution", "Data classification required", "Deduplication key", "Restricted to", "then open it up to"
    ]

    expect(field_labels).to match_array(expected_labels)
  end

  it 'does not contain the Relationships link when normal user' do
    expect(page).not_to have_link('Relationships', class: 'nav-link')
  end

  context 'Files tab' do
    it 'contains verbiage about file size limits' do
      click_on 'Files'
      expect(page).to have_content('Files must be less than 100MB in size.')
      expect(Hyrax.config.uploader[:maxFileSize]).to eq(104_857_600)
    end
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
