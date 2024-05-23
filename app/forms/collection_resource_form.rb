# frozen_string_literal: true

# Generated via
#  `rails generate hyrax:collection_resource CollectionResource`
class CollectionResourceForm < Hyrax::Forms::PcdmCollectionForm
  include Hyrax::FormFields(:emory_basic_metadata)
  include Hyrax::FormFields(:collection_resource)

  def primary_terms
    [:title, :creator, :description, :emory_ark, :holding_repository, :institution,
     :internal_rights_note, :system_of_record_ID, :administrative_unit,
     :contact_information]
  end

  def secondary_terms
    [:keyword, :rights_notes, :staff_notes, :subject, :subject_geo, :subject_names, :notes]
  end
end
