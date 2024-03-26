# frozen_string_literal: true

# Generated via
#  `rails generate hyrax:work_resource Publication`
#
# @see https://github.com/samvera/hyrax/wiki/Hyrax-Valkyrie-Usage-Guide#forms
# @see https://github.com/samvera/valkyrie/wiki/ChangeSets-and-Dirty-Tracking
class PublicationForm < Hyrax::Forms::PcdmObjectForm(Publication)
  include Hyrax::FormFields(:emory_basic_metadata)
  include Hyrax::FormFields(:publication_metadata)

  # Define custom form fields using the Valkyrie::ChangeSet interface
  #
  # property :my_custom_form_field

  # if you want a field in the form, but it doesn't have a directly corresponding
  # model attribute, make it virtual
  #
  # property :user_input_not_destined_for_the_model, virtual: true

  # To be used in place of #primary_terms or other built-in term collections within
  #   app/views/hyrax/base/_form_metadata.html.erb to feed desired fields
  #   to separate field groupings. Fields must be within an array in order of how they
  #   appear in the form, symbolized, and match the attribute names in their metadata YAMLS
  #   (e.g. config/metadata/publication_metadata.yaml).
  def administrative_terms
    [:emory_ark, :rights_statement, :internal_rights_note, :staff_notes, :access_right,
     :system_of_record_ID, :emory_content_type, :holding_repository, :institution,
     :data_classification, :date_created]
  end

  def publication_information
    [:title, :creator, :language, :date_issued, :publisher, :publisher_version,
     :rights_statement, :license, :final_published_versions, :parent_title, :conference_name,
     :issn, :series_title, :edition, :volume, :issue, :page_range_start, :page_range_end,
     :place_of_production, :sponsor, :grant_agencies, :grant_information, :related_datasets]
  end

  def additional_information
    [:abstract, :author_notes, :subject]
  end

  def genres_block
    [:content_genres]
  end
end
