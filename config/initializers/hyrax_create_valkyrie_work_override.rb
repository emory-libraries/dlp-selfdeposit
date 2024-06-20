# frozen_string_literal: true
# [Hyrax-overwrite-v5.0.1] - Adds set_noid step

require './lib/hyrax/transactions/steps/set_noid_id'

# registers Step across whole application
Hyrax::Transactions::Container.register('change_set.set_noid_id', Hyrax::Transactions::Steps::SetNoidId.new)
# adds `#set_noid_id` to default steps so that it passes `#step?` test in Container's initialization methods.
Hyrax::Transactions::WorkCreate::DEFAULT_STEPS = ['change_set.set_default_admin_set',
                                                  'change_set.ensure_admin_set',
                                                  'change_set.set_user_as_depositor',
                                                  'change_set.apply',
                                                  'change_set.set_noid_id',
                                                  'work_resource.apply_permission_template',
                                                  'work_resource.save_acl',
                                                  'work_resource.add_file_sets',
                                                  'work_resource.change_depositor',
                                                  'work_resource.add_to_parent'].freeze
Hyrax::Transactions::CollectionCreate::DEFAULT_STEPS = ['change_set.set_user_as_depositor',
                                                        'change_set.set_collection_type_gid',
                                                        'change_set.add_to_collections',
                                                        'change_set.apply',
                                                        'change_set.set_noid_id',
                                                        'collection_resource.apply_collection_type_permissions',
                                                        'collection_resource.save_acl'].freeze

Rails.application.config.to_prepare do
  Hyrax::Action::CreateValkyrieWork.class_eval do
    # includes `#set_noid_id` as a step in work creation.
    def step_args
      # rubocop:disable Style/HashSyntax
      {
        'change_set.set_noid_id' => {},
        'work_resource.add_to_parent' => { parent_id: params[:parent_id], user: user },
        'work_resource.add_file_sets' => { uploaded_files: uploaded_files, file_set_params: work_attributes[:file_set] },
        'change_set.set_user_as_depositor' => { user: user },
        'work_resource.change_depositor' => { user: ::User.find_by_user_key(form.on_behalf_of) },
        'work_resource.save_acl' => { permissions_params: form.input_params["permissions"] }
      }
      # rubocop:enable Style/HashSyntax
    end
  end
end


