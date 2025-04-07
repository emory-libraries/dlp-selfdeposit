# frozen_string_literal: true

require 'rails_helper'
include Warden::Test::Helpers

RSpec.describe 'Sidekiq UI', :clean_repo, type: :feature do
  context 'as a non-admin user' do
    before { login_as FactoryBot.create(:user) }

    it 'redirects to login page' do
      expect { visit '/sidekiq' }.to raise_exception ActionController::RoutingError
    end
  end

  context 'as an admin user' do
    let(:admin) { FactoryBot.create(:admin) }
    before do
      admin.roles << Role.find_or_create_by(name: Hyrax.config.admin_user_group_name)
      admin.save
      login_as admin
      visit '/sidekiq'
      click_on 'Busy'
    end

    it('view the active sidekiq queues') { expect(page).to have_content 'Processes' }
  end

  context 'when no user is signed in' do
    it 'redirects to login page' do
      visit '/sidekiq'
      expect(page.current_path).to include('/sign_in')
    end
  end
end
