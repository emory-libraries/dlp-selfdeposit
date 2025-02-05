# frozen_string_literal: true
class SolrDocument
  include Blacklight::Solr::Document
  include Blacklight::Gallery::OpenseadragonSolrDocument

  # Adds Hyrax behaviors to the SolrDocument.
  include Hyrax::SolrDocumentBehavior

  # self.unique_key = 'id'

  # Email uses the semantic field mappings below to generate the body of an email.
  SolrDocument.use_extension(Blacklight::Document::Email)

  # SMS uses the semantic field mappings below to generate the body of an SMS email.
  SolrDocument.use_extension(Blacklight::Document::Sms)

  # DublinCore uses the semantic field mappings below to assemble an OAI-compliant Dublin Core document
  # Semantic mappings of solr stored fields. Fields may be multi or
  # single valued. See Blacklight::Document::SemanticFields#field_semantics
  # and Blacklight::Document::SemanticFields#to_semantic_values
  # Recommendation: Use field names from Dublin Core
  use_extension(Blacklight::Document::DublinCore)

  # Do content negotiation for AF models.

  use_extension(Hydra::ContentNegotiation)

  def file_path
    self['file_path_ssim']
  end

  def creating_application_name
    self['creating_application_name_ssim']
  end

  def creating_os
    self['creating_os_ssim']
  end

  def persistent_unique_identification
    self['puid_ssim']
  end

  def original_checksum
    self['original_checksum_ssim']
  end

  def preservation_events
    self['preservation_events_tesim']
  end

  def title_label_or_filename
    title&.first&.presence || label&.first&.presence || self['original_filename_ssi']
  end

  def emory_persistent_id
    self['emory_persistent_id_ssi']
  end

  def holding_repository
    self['holding_repository_ssi']
  end

  def institution
    self['institution_ssi']
  end

  def contact_information
    self['contact_information_ssi']
  end

  def subject_geo
    self['subject_geo_ssim']
  end

  def subject_names
    self['subject_names_ssim']
  end

  def notes
    self['notes_ssim']
  end

  def emory_ark
    self['emory_ark_tesim']
  end

  # rubocop:disable Naming/MethodName
  def system_of_record_ID
    self['system_of_record_ID_ssi']
  end
  # rubocop:enable Naming/MethodName

  def staff_notes
    self['staff_notes_tesim']
  end

  def internal_rights_note
    self['internal_rights_note_tesi']
  end

  def administrative_unit
    self['administrative_unit_ssi']
  end
end
