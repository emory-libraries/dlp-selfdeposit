# frozen_string_literal: true
require 'rails_helper'

RSpec.describe BatchAddPublicationsToCollectionJob do
  let(:user) { FactoryBot.create(:user) }
  let(:collection_id) { '123456-cor' }
  let(:member_ids_array) { ['789123-cor'] }

  it "calls Hyrax::Collections::CollectionMemberService#add_members_by_ids" do
    allow(Hyrax::Collections::CollectionMemberService).to receive(:add_members_by_ids)
    described_class.perform_now(collection_id:, member_ids_array:, user:)

    expect(Hyrax::Collections::CollectionMemberService)
      .to have_received(:add_members_by_ids)
      .with(collection_id:, new_member_ids: member_ids_array, user:)
  end

  context "when collection_id is unset" do
    let(:collection_id) { nil }
    let(:env_collection_id) { '123abc-cor' }

    it "calls Hyrax::Collections::CollectionMemberService#add_members_by_ids" do
      ENV['OPENEMORY_COLLECTION_ID'] = env_collection_id
      allow(Hyrax::Collections::CollectionMemberService).to receive(:add_members_by_ids)
      described_class.perform_now(collection_id:, member_ids_array:, user:)

      expect(Hyrax::Collections::CollectionMemberService)
        .to have_received(:add_members_by_ids)
        .with(collection_id: env_collection_id, new_member_ids: member_ids_array, user:)
    end
  end
end
