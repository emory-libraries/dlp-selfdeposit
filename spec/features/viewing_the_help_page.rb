# frozen_string_literal: true
require 'rails_helper'

RSpec.describe 'viewing the help page', type: :feature do
  before { visit '/help' }

  context 'headers and meta tags' do
    it 'contains the expected title tag in header' do
      expect(page).to have_css 'head title', text: 'Help', visible: false
    end
  end
end
