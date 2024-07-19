# frozen_string_literal: true
namespace :selfdeposit do
  namespace :publications do
    desc "Automate setup of OE Admin Set, Collection Type and Collection"
    task setup_admin_set_collection: :environment do
      ENV.fetch('OPENEMORY_WORKFLOW_ADMIN_SET_ID', Hyrax::AdminSetCreateService.find_or_create_default_admin_set.id.to_s)
      col_type = CollectionType.find_or_create_library_collection_type
      make_default_collection(col_type)
    end
  end
end

def make_default_collection(col_type)
  col_exists = Hyrax.custom_queries.find_by_collection_title(title: "OpenEmory")
  return if col_exists.present?
  desc = ['OpenEmory preserves scholarly publications from Emory faculty, graduate,
           and undergraduate researchers and makes them freely accessible, increasing the visibility
           of this research and furthering the intellectual community at Emory University.']
  col = Collection.new(title: ["OpenEmory"], description: desc, creator: ['Emory University'], holding_repository: ['Emory University. Library'],
                       institution: ['Emory University'], collection_type_gid: col_type.to_global_id.to_s, visibility: 'open')
  change_set = Hyrax::ChangeSet.for(col)
  tx = Hyrax::Transactions::CollectionCreate.new
  tx.with_step_args('change_set.set_noid_id' => {}).call(change_set)
end
