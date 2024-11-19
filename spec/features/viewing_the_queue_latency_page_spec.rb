# frozen_string_literal: true
require 'rails_helper'

RSpec.describe "viewing the queue-latency page", type: :feature do
  before { visit '/queue-latency' }

  it('successfully loads') { expect(page).to have_http_status(:success) }
  it('returns plain text') { expect(page.response_headers['Content-Type']).to eq('text/plain') }
  it('contains the expected verbiage') { expect(page.html).to include('queue latency in seconds:') }

  it 'calls the Sidekiq queue API' do
    allow(::Sidekiq::Queue).to receive(:all).and_call_original
    expect(::Sidekiq::Queue).to receive(:all)

    visit '/queue-latency'
  end
end
