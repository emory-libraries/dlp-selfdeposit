# frozen_string_literal: true
require 'rails_helper'
require 'hyrax/specs/shared_specs/factories/administrative_sets'

RSpec.describe RemediateObjectsLackingPreservationEventsJob, :clean do
  let(:user) { FactoryBot.create(:user) }
  let(:admin_set) { FactoryBot.valkyrie_create(:hyrax_admin_set) }
  let(:publication) { FactoryBot.valkyrie_create(:publication, deduplication_key: '1234reet', admin_set_id: admin_set.id, depositor: user.user_key) }

  before do
    Hyrax.index_adapter.wipe!
    publication
  end

  it "adds preservation events to publication lacking it" do
    expect { described_class.perform_now }.to change { Hyrax.query_service.find_by(id: publication.id).preservation_events }
  end
end
