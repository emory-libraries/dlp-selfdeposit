# frozen_string_literal: true
# [Hyrax-override-v5.2.0] - SelfDeposit retroactive bug fix
#   This checks for the existence of the FileSet's Title value
#   and inserts the UploadFile's filename if missing.

Rails.application.config.to_prepare do
  Hyrax::FileSetsController.class_eval do
    def valkyrie_update_metadata
      change_set = Hyrax::Forms::ResourceForm.for(resource: file_set)

      attributes = coerce_valkyrie_params
      attributes['title'] = [file_set.original_file.original_filename] if file_set.title.empty?

      # TODO: We are not performing any error checks.  So that's something to
      # correct.
      result =
        change_set.validate(attributes) &&
        transactions['change_set.update_file_set']
        .with_step_args(
            'file_set.save_acl' => { permissions_params: change_set.input_params["permissions"] }
          )
        .call(change_set).value_or { false }
      @file_set = result if result
    end
  end
end
