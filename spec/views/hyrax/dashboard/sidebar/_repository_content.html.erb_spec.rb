# frozen_string_literal: true
require 'rails_helper'

RSpec.describe 'hyrax/dashboard/sidebar/_repository_content.html.erb', type: :view do
  let(:ability) { double(can_import_works?: false, can_export_works?: false) }
  let(:menu) { Hyrax::MenuPresenter.new(ActionView::TestCase::TestController.new.view_context) }
  let(:page) do
    render('hyrax/dashboard/sidebar/repository_content', current_ability: ability, menu:)
    Capybara::Node::Simple.new(rendered)
  end

  context 'with any user' do
    it 'contains default links' do
      expect(page).to have_content 'Works'
      expect(page).to have_content 'Collections'
      expect(page).not_to have_content 'Importers'
      expect(page).not_to have_content 'Exporters'
    end
  end

  context 'with an admin' do
    let(:ability) { double(can_import_works?: true, can_export_works?: true) }

    it 'contains default links and Bulkrax options' do
      expect(page).to have_content 'Works'
      expect(page).to have_content 'Collections'
      expect(page).to have_content 'Importers'
      expect(page).to have_content 'Exporters'
    end
  end
end
