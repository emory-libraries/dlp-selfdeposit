# frozen_string_literal: true

module SelfDeposit
  class ValkyrieObjectRemediationService
    def self.migrate_alternate_ids_to_emory_persistent_id
      ::SelfDeposit::ReindexingService.reindex_all_metadata_objects
      operating_objs = pull_operating_ids
      process_objects_with_alternate_ids(operating_objs:)
      operating_objs.map { |obj| obj['id'] }.join(', ')
    end

    class << self
      private

      def pull_operating_ids
        Hyrax.custom_queries.find_all_object_ids_with_alternate_ids_present
      end

      def process_objects_with_alternate_ids(operating_objs:)
        operating_objs.each do |obj|
          pulled_object = Hyrax.query_service.find_by(id: obj['id'])
          value_in_alternate_ids = obj['alternate_ids_ssim'].first
          Rails.logger.info("Found object with id #{obj['id']}")

          pulled_object.emory_persistent_id = value_in_alternate_ids if pulled_object.emory_persistent_id.blank?
          pulled_object.alternate_ids = []
          Hyrax.persister.save(resource: pulled_object)
          Hyrax.index_adapter.save(resource: pulled_object)

          Rails.logger.info("Updated object with id #{obj['id']}")
        rescue => e
          Rails.logger.error "ID #{obj['id']} erred: #{e}"
          next
        end
      end
    end
  end
end
