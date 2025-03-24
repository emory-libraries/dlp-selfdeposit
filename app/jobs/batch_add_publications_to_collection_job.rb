# frozen_string_literal: true

class BatchAddPublicationsToCollectionJob < Hyrax::ApplicationJob
  def perform(collection_id: nil, member_ids_array:, user:)
    processed_collection_id = collection_id.presence || ENV.fetch('OPENEMORY_COLLECTION_ID', nil)
    Hyrax::Collections::CollectionMemberService.add_members_by_ids(collection_id: processed_collection_id,
                                                                   new_member_ids: member_ids_array,
                                                                   user:)
  end
end
