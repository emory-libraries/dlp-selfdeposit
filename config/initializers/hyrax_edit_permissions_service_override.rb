# frozen_string_literal: true
# [Hyrax-overwrite-v5.0.1] - Hyrax Bug!
#   When testing what type of form the application is using in the case of FileSets, the Hyrax::EditPermissionsService
#   relies on the out-of-box form class but ignores the fact that those using the Hyrax Rails Engine are given the choice
#   to replace that form with their own in the configuration. We're changing the explicit class to the configuration variable,
#   which defaults to Hyrax::Forms::FileSetForm.
#
# This change was submitted to Hyrax with the following PR: https://github.com/samvera/hyrax/pull/7121

Rails.application.config.to_prepare do
  Hyrax::EditPermissionsService.class_eval do
    ##
    # @api public
    # @since v3.0.0
    #
    # @param form [SimpleForm::FormBuilder]
    # @param current_ability [Ability]
    # @return [Hyrax::EditPermissionService]
    #
    # @note
    #   +form object.class = SimpleForm::FormBuilder+
    #    For works (i.e. GenericWork):
    #    * form_object.object = Hyrax::GenericWorkForm
    #    * form_object.object.model = GenericWork
    #    * use the work itself
    #    For file_sets:
    #    * form_object.object.class = FileSet
    #    * use work the file_set is in
    #    For file set forms:
    #    * form_object.object.class = Hyrax::Forms::FileSetForm (or what is set in Hyrax.config.file_set_form) OR Hyrax::Forms::FileSetEditForm
    #    * form_object.object.model = FileSet
    #    * use work the file_set is in
    #    No other object types are supported by this view.
    def self.build_service_object_from(form:, ability:)
      if form.object.respond_to?(:model) && form.object.model.work?
        # The provided form object is a work form.
        new(object: form.object, ability:)
      elsif form.object.respond_to?(:model) && form.object.model.file_set?
        # The provided form object is a FileSet form. For Valkyrie forms
        # (+Hyrax::Forms::FileSetForm+), +:in_works_ids+ is prepopulated onto
        # the form object itself. For +Hyrax::Forms::FileSetEditForm+, the
        # +:in_works+ method is present on the wrapped +:model+.
        if form.object.is_a?(Hyrax.config.file_set_form)
          object_id = form.object.in_works_ids.first
          new(object: Hyrax.query_service.find_by(id: object_id), ability:)
        else
          new(object: form.object.model.in_works.first, ability:)
        end
      elsif form.object.file_set?
        # The provided form object is a FileSet.
        new(object: form.object.in_works.first, ability:)
      end
    end
  end
end
