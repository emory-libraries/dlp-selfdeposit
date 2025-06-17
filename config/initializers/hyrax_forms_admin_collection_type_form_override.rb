# frozen_string_literal: true
# Hyrax v5.0 Override - brings in collection query optimization from v5.1.
#   Please delete after moving to Hyrax >=v5.1.

Rails.application.config.to_prepare do
  Hyrax::Forms::Admin::CollectionTypeForm.class_eval do
    delegate :collections?, to: :collection_type
  end
end
