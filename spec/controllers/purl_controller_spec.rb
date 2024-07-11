# frozen_string_literal: true
require 'rails_helper'
require 'hyrax/specs/shared_specs/factories/administrative_sets'
require 'hyrax/specs/shared_specs/factories/hyrax_collection'
require 'hyrax/specs/shared_specs/factories/permission_templates'
require 'hyrax/specs/shared_specs/factories/workflows'

RSpec.describe PurlController, :clean_repo, type: :controller do
  describe 'GET #redirect_to_original' do
    let(:base_url) { 'test.host' }
    let(:user) { FactoryBot.create(:user) }
    let(:admin_set) { FactoryBot.valkyrie_create(:hyrax_admin_set) }
    let(:permission_template) { FactoryBot.create(:permission_template, source_id: admin_set.id) }
    let(:workflow) { FactoryBot.create(:workflow, allows_access_grant: true, active: true, permission_template_id: permission_template.id) }
    let(:publication_alt_ids) { ['1234567-emory'] }
    let!(:publication) { FactoryBot.valkyrie_create(:publication, with_index: true, admin_set_id: admin_set.id, depositor: user.user_key, alternate_ids: publication_alt_ids) }
    let(:collection_alt_ids) { ['89abcef-emory'] }
    let!(:collection) { FactoryBot.valkyrie_create(:hyrax_collection, alternate_ids: collection_alt_ids) }

    before do
      Hyrax.index_adapter.wipe!
      request.host = base_url
    end

    context 'when purl_object is a Publication' do
      it 'redirects to the publication URL' do
        Hyrax.index_adapter.save(resource: publication)
        get :redirect_to_original, params: { alternate_ids: publication_alt_ids.first }

        expect(response).to redirect_to("http://test.host/concern/publications/#{publication.id}")
      end
    end

    context 'when purl_object is a Collection' do
      it 'redirects to the collection URL' do
        Hyrax.index_adapter.save(resource: collection)
        get :redirect_to_original, params: { alternate_ids: collection_alt_ids.first }

        expect(response).to redirect_to("http://test.host/collections/#{collection.id}")
      end
    end

    context 'when purl_object is not found' do
      before do
        get :redirect_to_original, params: { alternate_ids: admin_set.id }
      end

      it 'returns a 404 not found status' do
        expect(response).to have_http_status(:not_found)
        expect(response.body).to eq('Item not found')
      end
    end
  end
end
