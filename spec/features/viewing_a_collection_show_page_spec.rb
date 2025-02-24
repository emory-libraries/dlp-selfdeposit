# frozen_string_literal: true
require 'rails_helper'
require 'hyrax/specs/shared_specs/factories/hyrax_collection'
include Warden::Test::Helpers

RSpec.describe 'viewing a Collection show page', type: :feature do
  let(:user) { FactoryBot.create(:user) }
  selector_value_array = [
    ['.hyc-title', 'A Good Title'],
    ['.hyc-description', 'A good description.'],
    ['.col-sm-10 dd', 'Tom Wolfe'],
    ['.col-sm-10 dd', '12345678-cor'],
    ['.col-sm-10 dd', 'Emory University. Library'],
    ['.col-sm-10 dd', 'Emory University'],
    ['.col-sm-10 dd', '4075555555'],
    ['.col-sm-10 dd', 'book'],
    ['.col-sm-10 dd', 'Southern States'],
    ['.col-sm-10 dd', 'Atlanta, Georgia, USA'],
    ['.col-sm-10 dd', 'Radley, Boo'],
    ['.col-sm-10 dd', 'A note about rights.'],
    ['.col-sm-10 dd', 'A gernal note.']
  ]

  admin_selector_value_array = [
    ['.col-sm-10 dd', 'doi:123456'],
    ['.col-sm-10 dd', '12345789'],
    ['.col-sm-10 dd', 'A note from a staff member.'],
    ['.col-sm-10 dd', 'An internal note about rights.'],
    ['.col-sm-10 dd', 'Faculty']
  ]

  dashboard_selector_value_array = [
    ['.collection-title', 'A Good Title'],
    ['.collection-description-wrapper section', 'A good description.'],
    ['.row dd.col-7', 'Tom Wolfe'],
    ['.row dd.col-7', '12345678-cor'],
    ['.row dd.col-7', 'Emory University. Library'],
    ['.row dd.col-7', 'Emory University'],
    ['.row dd.col-7', '4075555555'],
    ['.row dd.col-7', 'book'],
    ['.row dd.col-7', 'Southern States'],
    ['.row dd.col-7', 'Atlanta, Georgia, USA'],
    ['.row dd.col-7', 'Radley, Boo'],
    ['.row dd.col-7', 'A note about rights.'],
    ['.row dd.col-7', 'A gernal note.']
  ]

  dashboard_admin_selector_value_array = [
    ['.row dd.col-7', 'doi:123456'],
    ['.row dd.col-7', '12345789'],
    ['.row dd.col-7', 'A note from a staff member.'],
    ['.row dd.col-7', 'An internal note about rights.'],
    ['.row dd.col-7', 'Faculty']
  ]

  shared_examples 'checks for expected values' do |user_type, test_array|
    it "contains the expected values when #{user_type} user" do
      test_array.each do |selector, value|
        expect(page).to have_selector(selector, text: value)
      end
    end
  end

  shared_examples 'checks for lack of expected values' do |user_type, test_array|
    it "contains the expected values when #{user_type} user" do
      test_array.each do |selector, value|
        expect(page).not_to have_selector(selector, text: value)
      end
    end
  end

  let(:collection) do
    FactoryBot.valkyrie_create(
      :hyrax_collection,
      :public,
      title: ['A Good Title'],
      description: 'A good description.',
      creator: ['Tom Wolfe'],
      emory_persistent_id: '12345678-cor',
      holding_repository: 'Emory University. Library',
      institution: 'Emory University',
      contact_information: '4075555555',
      keyword: ['book', 'fiction'],
      subject: ['Southern States'],
      subject_geo: ['Atlanta, Georgia, USA'],
      subject_names: ['Radley, Boo'],
      rights_notes: ['A note about rights.'],
      notes: ['A gernal note.'],
      emory_ark: ['doi:123456'],
      system_of_record_ID: '12345789',
      staff_notes: ['A note from a staff member.'],
      internal_rights_note: 'An internal note about rights.',
      administrative_unit: 'Faculty'
    )
  end

  before do
    visit "/collections/#{collection.id}"
  end

  include_examples 'checks for expected values', 'normal', selector_value_array
  include_examples 'checks for lack of expected values', 'normal', admin_selector_value_array

  context 'when admin logged in' do
    before do
      # the below code adds the admin role to user
      user.roles << Role.find_or_create_by(name: Hyrax.config.admin_user_group_name)
      user.save
      login_as user
      visit "/collections/#{collection.id}"
    end

    include_examples 'checks for expected values', 'admin', selector_value_array
    include_examples 'checks for expected values', 'admin', admin_selector_value_array
  end

  describe 'dashboard collection show page' do
    before do
      login_as user
      visit "/dashboard/collections/#{collection.id}"
    end

    include_examples 'checks for expected values', 'normal', dashboard_selector_value_array
    include_examples 'checks for lack of expected values', 'normal', dashboard_admin_selector_value_array

    context 'when admin logged in' do
      before do
        # the below code adds the admin role to user
        user.roles << Role.find_or_create_by(name: Hyrax.config.admin_user_group_name)
        user.save
        login_as user
        visit "/dashboard/collections/#{collection.id}"
      end

      include_examples 'checks for expected values', 'admin', dashboard_selector_value_array
      include_examples 'checks for expected values', 'admin', dashboard_admin_selector_value_array
    end
  end
end
