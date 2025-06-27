# frozen_string_literal: true
require 'rails_helper'
require 'hyrax/specs/shared_specs/factories/administrative_sets'

RSpec.describe FileSetsInPublicationsCountReportJob, :clean do
  let(:user) { FactoryBot.create(:user) }
  let(:admin_set) { FactoryBot.valkyrie_create(:hyrax_admin_set) }
  let(:file_set) { FactoryBot.valkyrie_create(:hyrax_file_set, :with_files, depositor: user.user_key, read_groups: ['public'], edit_users: [user]) }
  let(:publication) { FactoryBot.valkyrie_create(:publication, deduplication_key: '1234reet', admin_set_id: admin_set.id, depositor: user.user_key, members: [file_set]) }

  before do
    Hyrax.index_adapter.wipe!
    publication
  end

  it "calls the CSV service to create a report" do
    allow(CSV).to receive(:open)
    described_class.perform_now

    expect(CSV).to have_received(:open)
  end
end
