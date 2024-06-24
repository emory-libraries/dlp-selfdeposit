# frozen_string_literal: true
require 'rails_helper'
include Warden::Test::Helpers

RSpec.describe 'viewing the root page', type: :system do
  it 'has the welcome text' do
    visit root_path

    expect(page).to have_content('Emory Libraries')
  end
end
