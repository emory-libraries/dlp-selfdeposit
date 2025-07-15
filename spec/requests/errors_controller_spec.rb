# frozen_string_literal: true
require "rails_helper"

RSpec.describe ErrorsController, type: :request do
  context '404 error' do
    let(:request) { -> { get '/books/1' } }

    it "loads the page when 404 error detected" do
      rails_respond_without_detailed_exceptions do
        request.call
      end

      # expect(response.status).to eq 404
      expect(response.body).not_to be_empty
      expect(response.content_length).to be > 0
      expect(response.content_type).to eq 'text/html; charset=utf-8'
      expect(response).to render_template(:not_found)
    end
  end
end
