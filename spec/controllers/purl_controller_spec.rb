# frozen_string_literal: true
require 'rails_helper'

RSpec.describe PurlController, type: :controller do
  describe 'GET #redirect_to_original' do
    let(:base_url) { 'test.host' }
    let(:alternate_ids) { 'test-alternate-id' }
    let(:solr_object) { double('solr_object') }

    before do
      allow(Hyrax.custom_queries).to receive(:find_by_alternate_id).and_return(solr_object)
      request.host = base_url
    end

    context 'when solr_object is a Publication' do
      before do
        allow(solr_object).to receive(:has_model).and_return(['Publication'])
        allow(solr_object).to receive(:id).and_return('123')
        get :redirect_to_original, params: { alternate_ids: }
      end

      it 'redirects to the publication URL' do
        expect(response).to redirect_to("http://test.host/concern/publications/123")
      end
    end

    context 'when solr_object is a Collection' do
      before do
        allow(solr_object).to receive(:has_model).and_return(nil)
        allow(solr_object).to receive(:respond_to?).with(:collection_type_gid).and_return(true)
        allow(solr_object).to receive(:collection_type_gid).and_return('gid://internal/Collection')
        allow(solr_object).to receive(:id).and_return('456')
        get :redirect_to_original, params: { alternate_ids: }
      end

      it 'redirects to the collection URL' do
        expect(response).to redirect_to("http://test.host/collections/456")
      end
    end

    context 'when solr_object is not found' do
      before do
        allow(solr_object).to receive(:has_model).and_return(nil)
        allow(solr_object).to receive(:respond_to?).with(:collection_type_gid).and_return(false)
        get :redirect_to_original, params: { alternate_ids: }
      end

      it 'returns a 404 not found status' do
        expect(response).to have_http_status(:not_found)
        expect(response.body).to eq('Item not found')
      end
    end
  end
end
