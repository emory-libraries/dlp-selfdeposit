
# frozen_string_literal: true
class CollectionType < Hyrax::CollectionType
  USER_COLLECTION_DEFAULT_TITLE = 'Library Collection'
  after_initialize :configure

  # If a Curate::CollectionType already exists, ensure it adheres to expectations and return it.
  # Otherwise, make a new one and return that.
  def self.find_or_create_library_collection_type
    library_collection_type = CollectionType.find_by_title(USER_COLLECTION_DEFAULT_TITLE)
    library_collection_type = CollectionType.new if library_collection_type.nil?
    library_collection_type.configure
    library_collection_type
  end

  def configure
    self.title = USER_COLLECTION_DEFAULT_TITLE
    self.description = "Library staff curated collections"
    self.allow_multiple_membership = false
    save
    remove_all_participants
    allow_admins_to_manage
  end

  # Remove all participants from the collection type and only add back in admins
  def remove_all_participants
    Hyrax::CollectionTypeParticipant.where(hyrax_collection_type_id: id).all.find_each(&:destroy!)
  end

  def allow_admins_to_manage
    h = Hyrax::CollectionTypeParticipant.new
    h.hyrax_collection_type_id = id
    h.agent_type = "group"
    h.agent_id = "admin"
    h.access = "manage"
    h.save
  end

  # @return [Boolean] True if there is at least one collection type that has nestable? true
  def self.any_nestable?
    any?(&:nestable)
  end

  # Hyrax v5.0 Override - brings in collection query optimization from v5.1.
  #   Please delete after moving to Hyrax >=v5.1.
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
    return true unless admin_set? && collection_type_settings_changed? && exists_for_machine_id?(ADMIN_SET_MACHINE_ID)
    errors.add(:base, I18n.t('hyrax.admin.collection_types.errors.no_settings_change_for_admin_sets'))
    throw :abort
  end

  def ensure_no_settings_changes_for_user_collection_type
    return true unless user_collection? && collection_type_settings_changed? && exists_for_machine_id?(USER_COLLECTION_MACHINE_ID)
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
