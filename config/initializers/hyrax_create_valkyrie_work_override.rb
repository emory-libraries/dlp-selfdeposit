# frozen_string_literal: true
# [Hyrax-overwrite-v5.0.1] - Adds set_noid step
Rails.application.config.to_prepare do
  Hyrax::Action::CreateValkyrieWork.class_eval do
    def step_args
      # rubocop:disable Style/HashSyntax
      {
        'change_set.set_noid_id' => { alternate_ids: [] },
        'work_resource.add_to_parent' => { parent_id: params[:parent_id], user: user },
        'work_resource.add_file_sets' => { uploaded_files: uploaded_files, file_set_params: work_attributes[:file_set] },
        'change_set.set_user_as_depositor' => { user: user },
        'work_resource.change_depositor' => { user: ::User.find_or_create_by_user_key(form.on_behalf_of) },
        'work_resource.save_acl' => { permissions_params: form.input_params["permissions"] }
      }
      # rubocop:enable Style/HashSyntax
    end
  end
end
