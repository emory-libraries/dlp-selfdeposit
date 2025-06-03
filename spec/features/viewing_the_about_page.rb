# frozen_string_literal: true
require 'rails_helper'

RSpec.describe 'viewing the about page', type: :feature do
  before { visit '/about' }

  context 'headers and meta tags' do
    it 'contains the expected title tag in header' do
      expect(page).to have_css 'head title', text: 'About OpenEmory', visible: false
    end
  end
end
