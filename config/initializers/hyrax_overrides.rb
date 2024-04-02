# frozen_string_literal: true
Rails.application.config.to_prepare do
  Hyrax::Forms::FileSetForm.include EmoryFileSetMetadataExtension
  Hyrax::Forms::FileSetEditForm.include EmoryFileSetMetadataExtension
end
