# frozen_string_literal: true
# [Hyrax-override-v5.2.0]
# We have removed json_response tests from here since we are
# no longer rendering json in our create method
require 'rails_helper'

RSpec.describe Hyrax::FixityChecksController, type: :controller do
  include Devise::Test::ControllerHelpers

  routes { Hyrax::Engine.routes }
  let(:user) { FactoryBot.create(:user) }
  let!(:file_set) do
    FactoryBot.valkyrie_create(:hyrax_file_set, :with_files, title: ['Test File Set'], depositor: user.user_key, read_groups: ['public'], edit_users: [user])
  end

  context "when signed in" do
    describe "POST create" do
      before do
        sign_in user
        post :create, params: { file_set_id: file_set.id }, xhr: true
      end

      it "returns result and redirects to file_set page" do
        expect(response.status).to eq(302)
        expect(response.redirect_url).to include "/concern/file_sets/#{file_set.id}"
      end
    end
  end

  context "when not signed in" do
    describe "POST create" do
      it "returns json with the result" do
        post :create, params: { file_set_id: file_set.id }, xhr: true
        expect(response.code).to eq '401'
      end
    end
  end
end
