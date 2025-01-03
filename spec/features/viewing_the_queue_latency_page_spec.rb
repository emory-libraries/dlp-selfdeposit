# frozen_string_literal: true
require 'rails_helper'

RSpec.describe "viewing the queue-latency page", type: :feature do
  before { visit '/queue-latency' }

  it('successfully loads') { expect(page).to have_http_status(:success) }
  it('returns plain text') { expect(page.response_headers['Content-Type']).to eq('application/json') }
  # It seems that Circle CI doesn't inherently spin up a queue.
  it('contains the expected JSON') do
    parsed_json = JSON.parse(page.body)
    expect(parsed_json).to be_present
    expect(parsed_json['queues']).to be_present
  end unless ENV['CI']

  it 'calls the Sidekiq queue API' do
    allow(::Sidekiq::Queue).to receive(:all).and_call_original
    expect(::Sidekiq::Queue).to receive(:all)

    visit '/queue-latency'
  end
end
