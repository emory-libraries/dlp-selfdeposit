# frozen_string_literal: true
namespace :selfdeposit do
  namespace :publications do
    desc "Automate setup of OE Admin Set, Collection Type and Collection"
    task setup_admin_set_collection: :environment do
      ENV.fetch('OPENEMORY_WORKFLOW_ADMIN_SET_ID', Hyrax::AdminSetCreateService.find_or_create_default_admin_set.id.to_s)
      CollectionType.find_or_create_library_collection_type
    end
  end
end
