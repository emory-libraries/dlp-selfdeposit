# frozen_string_literal: true

module SelfDeposit
  class ValkyrieObjectRemediationService
    def self.migrate_alternate_ids_to_emory_persistent_id
      ::SelfDeposit::ReindexingService.reindex_all_metadata_objects
      operating_ids = pull_operating_ids
      process_objects_with_alternate_ids(operating_ids:)
      operating_ids.join(', ')
    end

    class << self
      private

      def pull_operating_ids
        Hyrax.custom_queries.find_all_object_ids_with_alternate_ids_present
      end

      def process_objects_with_alternate_ids(operating_ids:)
        operating_ids.each do |id|
          pulled_object = Hyrax.query_service.find_by(id:)
          value_in_alternate_ids = pulled_object.alternate_ids.map(&:to_s).first
          pulled_object.emory_persistent_id = value_in_alternate_ids if pulled_object.emory_persistent_id.blank?
          pulled_object.alternate_ids = []
          Hyrax.persister.save(resource: pulled_object)
          Hyrax.index_adapter.save(resource: pulled_object)
        end
      end
    end
  end
end
