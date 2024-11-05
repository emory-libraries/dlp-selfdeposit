# frozen_string_literal: true

module SelfDeposit
  class ValkyrieObjectRemediationService
    def self.migrate_alternate_ids_to_emory_persistent_id
      operating_ids = pull_operating_ids
      process_objects_with_alternate_ids
      operating_ids
    end

    class << self
      private

      def objects_with_alternate_ids
        Hyrax.custom_queries.find_all_objects_with_alternate_ids_present
      end

      def pull_operating_ids
        objects_with_alternate_ids.map(&:id).join(', ')
      end

      def process_objects_with_alternate_ids
        objects_with_alternate_ids.each do |obj|
          value_in_alternate_ids = obj.alternate_ids.map(&:to_s).first
          obj.emory_persistent_id = value_in_alternate_ids if obj.emory_persistent_id.blank?
          obj.alternate_ids = []
          Hyrax.persister.save(resource: obj)
        end
      end
    end
  end
end
