# frozen_string_literal: true
# Hyrax v5.0 Override - brings in collection query optimization from v5.1.
#   Please delete after moving to Hyrax >=v5.1.

Rails.application.config.to_prepare do
  Hyrax::CollectionType.class_eval do
    # Query solr to see if any collections of this type exist
    # This should be much more performant for certain adapters than calling collections.any?
    # @return [Boolean] True if there are any collections of this collection type in the repository
    def collections?
      return false unless id
      Hyrax::SolrQueryService.new
                             .with_field_pairs(field_pairs: { Hyrax.config.collection_type_index_field.to_sym => to_global_id.to_s })
                             .with_model(model: Hyrax.config.collection_class.to_rdf_representation)
                             .count
                             .positive?
    end

    private

    def ensure_no_collections
      return true unless collections?
      errors.add(:base, I18n.t('hyrax.admin.collection_types.errors.not_empty'))
      throw :abort
    end

    def ensure_no_settings_changes_for_admin_set_type
      return true unless admin_set? && collection_type_settings_changed? && exists_for_machine_id?(::Hyrax::CollectionType::ADMIN_SET_MACHINE_ID)
      errors.add(:base, I18n.t('hyrax.admin.collection_types.errors.no_settings_change_for_admin_sets'))
      throw :abort
    end

    def ensure_no_settings_changes_for_user_collection_type
      return true unless user_collection? && collection_type_settings_changed? && exists_for_machine_id?(::Hyrax::CollectionType::USER_COLLECTION_MACHINE_ID)
      errors.add(:base, I18n.t('hyrax.admin.collection_types.errors.no_settings_change_for_user_collections'))
      throw :abort
    end

    def ensure_no_settings_changes_if_collections_exist
      return true unless collections?
      return true unless collection_type_settings_changed?
      errors.add(:base, I18n.t('hyrax.admin.collection_types.errors.no_settings_change_if_not_empty'))
      throw :abort
    end
    # End of collection query optimization override.
  end
end
