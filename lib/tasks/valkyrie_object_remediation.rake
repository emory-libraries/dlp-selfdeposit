# frozen_string_literal: true
namespace :selfdeposit do
  namespace :valkyrie_object_remediation do
    desc "Moves 'alternate_ids' values to 'emory_persistent_id'."
    task migrate_alternate_ids_to_emory_persistent_id: :environment do
      operating_ids = ::SelfDeposit::ValkyrieObjectRemediationService.migrate_alternate_ids_to_emory_persistent_id

      puts "Valkyrie object IDs remediated: #{operating_ids}"
    end
  end
end
