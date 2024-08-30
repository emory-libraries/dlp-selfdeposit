# frozen_string_literal: true
require 'rails_helper'

RSpec.describe "hyrax/base/_attribute_rows.html.erb", type: :view do
  let(:solr_doc_attributes) do
    {
      id: '123445-cor',
      alternate_ids_ssim: ['904dncjsz6-emory'],
      date_modified_dtsi: "2024-05-12 20:26:26 UTC",
      title_tesim: ["Test Publication"],
      abstract_tesim: ['an abstraction'],
      creator_ssim: ['Tom, Collins, Gin University'],
      emory_ark_tesim: ['867-5309'],
      holding_repository_ssi: 'Emory University. Library',
      institution_ssi: 'Emory University',
      internal_rights_note_tesi: 'A note about internal rights.',
      keyword_tesim: ['keyword', 'books'],
      publisher_tesim: ['Simon & Schusters'],
      license_tesi: 'https://creativecommons.org/licenses/by-sa/4.0/',
      staff_notes_tesim: ['Oy, this staff!'],
      subject_tesim: ['Mathematics'],
      system_of_record_ID_ssi: '12345abcde',
      rights_notes_tesim: ['Rights notes a-go-go.'],
      author_notes_tesi: 'A note from the author.',
      conference_name_ssi: 'Samvera Connect',
      content_genre_ssi: 'Article',
      data_classification_ssi: 'Public',
      date_issued_ssi: '2004',
      deduplication_key_tesi: '83jhcf734jhg93g',
      edition_tesi: '1',
      emory_content_type_tesi: 'http://id.loc.gov/vocabulary/resourceTypes/txt',
      final_published_versions_tesim: ['10', '20'],
      grant_agencies_ssim: ['Rockfeller'],
      grant_information_tesim: ['Granted'],
      issn_tesi: 'fqefeefe2fed',
      isbn_tesi: 'dvqegr3gvfw',
      issue_tesi: '3',
      language_tesim: ['English'],
      page_range_end_tesi: '134',
      page_range_start_tesi: '1',
      parent_title_ssi: 'Parent title',
      place_of_production_ssi: 'Boston',
      publisher_version_ssi: 'Final Publisher PDF',
      related_datasets_ssim: ['A Dataset'],
      research_categories_ssim: ['Asian studies'],
      rights_statement_tesim: ['http://rightsstatements.org/vocab/InC/1.0/'],
      series_title_ssi: 'Series Title',
      sponsor_ssi: 'NEA',
      volume_tesi: '4'
    }
  end

  let(:solr_doc) { SolrDocument.new(solr_doc_attributes) }
  let(:ability) { double }
  let(:orcid_id) { '2222-2222-2222-2222' }
  let(:presenter) { Hyrax::WorkShowPresenter.new(solr_doc, ability) }
  let(:page) do
    render('hyrax/base/attribute_rows', presenter:)
    Capybara::Node::Simple.new(rendered)
  end

  # context 'typical user' do
  #   include_examples 'renders the expected lis', 2, ['PublicPublic', 'Embargo']
  # end

  # context 'admin user' do
  #   before { allow(user).to receive(:admin?).and_return(true) }

  #   include_examples 'renders the expected lis', 5, ["Embargo", "Institution", "Lease", "Private", "PublicPublic"]
  # end

  context 'typical user' do
    it "shows a publication's labels" do
      ["Persistent URL",
      "Last modified",
      "Type of Material",
      "Authors",
      "Language",
      "Date",
      "Publisher",
      "Publication Version",
      "License",
      "Final Published Version (URL)",
      "Title of Journal or Parent Work",
      "Conference or Event Name",
      "ISSN",
      "ISBN",
      "Series Title",
      "Edition",
      "Volume",
      "Issue",
      "Start Page",
      "End Page",
      "Place of Publication or Presentation",
      "Sponsor",
      "Grant/Funding Agency",
      "Grant/Funding Information",
      "Supplemental Material (URL)",
      "Abstract",
      "Author Notes",
      "Keywords",
      "Subject - Topics",
      "Research Categories"
    ].each do |label|
        expect(page).to have_selector 'dt', text: label
      end
    end
    it "shows a publication's values" do
      ["904dncjsz6-emory", "05/12/2024", "Article", "Tom Collins, Gin University", "English", "2004", "Simon & Schusters", "Final Publisher PDF", "Creative Commons Attribution-ShareAlike 4.0 International", "1020", "Parent title", "Samvera Connect", "fqefeefe2fed", "dvqegr3gvfw", "Series Title", "1", "4", "3", "1", "134", "Boston", "NEA", "Rockfeller", "Granted", "A Dataset", "an abstraction", "A note from the author.", "keywordbooks", "Mathematics", "Asian studies"].each do |value|
        expect(page).to have_selector 'dd', text: value
      end
    end
  end

  context 'admin user' do
    before { allow(user).to receive(:admin?).and_return(true) }
    it "shows a publication's labels" do
      ["Persistent URL", "Last modified", "Type of Material", "Authors", "Language", "Date", "Publisher", "Publication Version", "Copyright Status", "License", "Final Published Version (URL)", "Title of Journal or Parent Work", "Conference or Event Name", "ISSN", "ISBN", "Series Title", "Edition", "Volume", "Issue", "Start Page", "End Page", "Place of Publication or Presentation", "Sponsor", "Grant/Funding Agency", "Grant/Funding Information", "Supplemental Material (URL)", "Abstract", "Author Notes", "Keywords", "Subject - Topics", "Research Categories", "Emory ark", "Internal rights note", "Staff notes", "System of record id", "Format", "Holding repository", "Institution", "Data classification", "Deduplication key"].each do |label|
        expect(page).to have_selector 'dt', text: label
      end
    end
    it "shows a publication's values" do
      ["904dncjsz6-emory", "05/12/2024", "Article", "Tom Collins, Gin University", "English", "2004", "Simon & Schusters", "Final Publisher PDF", "In Copyright", "Creative Commons Attribution-ShareAlike 4.0 International", "1020", "Parent title", "Samvera Connect", "fqefeefe2fed", "dvqegr3gvfw", "Series Title", "1", "4", "3", "1", "134", "Boston", "NEA", "Rockfeller", "Granted", "A Dataset", "an abstraction", "A note from the author.", "keywordbooks", "Mathematics", "Asian studies", "867-5309", "A note about internal rights.", "Oy, this staff!", "12345abcde", "Text", "Emory University. Library", "Emory University", "Public", "83jhcf734jhg93g"].each do |value|
        expect(page).to have_selector 'dd', text: value
      end
    end
  end

  it "does not display an ORCID link when none is provided" do
    expect(page).not_to have_selector("a[href^='https://orcid.org/']")
  end

  it "updates and displays the orcid" do
    updated_attributes = solr_doc_attributes.merge(creator_ssim: ["Tom, Collins, Gin University, #{orcid_id}"])
    solr_doc = SolrDocument.new(updated_attributes)
    presenter = Hyrax::WorkShowPresenter.new(solr_doc, ability)
    render('hyrax/base/attribute_rows', presenter:)
    Capybara::Node::Simple.new(rendered)
    expect(rendered).to have_selector("a[href='https://orcid.org/#{orcid_id}']")
  end
end
