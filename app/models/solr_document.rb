# frozen_string_literal: true
class SolrDocument
  METHOD_ASSIGNMENTS = [
    ['administrative_unit', 'administrative_unit_ssi'],
    ['conference_name', 'conference_name_ssi'],
    ['contact_information', 'contact_information_ssi'],
    ['creating_application_name', 'creating_application_name_ssim'],
    ['creating_os', 'creating_os_ssim'],
    ['date_issued_year', 'date_issued_year_ssi'],
    ['emory_ark', 'emory_ark_tesim'],
    ['emory_persistent_id', 'emory_persistent_id_ssi'],
    ['file_path', 'file_path_ssim'],
    ['holding_repository', 'holding_repository_ssi'],
    ['institution', 'institution_ssi'],
    ['internal_rights_note', 'internal_rights_note_tesi'],
    ['isbn', 'isbn_tesi'],
    ['issn', 'issn_tesi'],
    ['issue', 'issue_tesi'],
    ['notes', 'notes_ssim'],
    ['original_checksum', 'original_checksum_ssim'],
    ['page_range_end', 'page_range_end_tesi'],
    ['page_range_start', 'page_range_start_tesi'],
    ['parent_title', 'parent_title_ssi'],
    ['persistent_unique_identification', 'puid_ssim'],
    ['preservation_events', 'preservation_events_tesim'],
    ['staff_notes', 'staff_notes_tesim'],
    ['subject_geo', 'subject_geo_ssim'],
    ['subject_names', 'subject_names_ssim'],
    ['volume', 'volume_tesi']
  ].freeze

  include Blacklight::Solr::Document
  include Blacklight::Gallery::OpenseadragonSolrDocument

  # Adds Hyrax behaviors to the SolrDocument.
  include Hyrax::SolrDocumentBehavior

  # Adds RIS citation
  include SelfDeposit::RisBehavior

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

  METHOD_ASSIGNMENTS.each do |method_name, solr_field|
    define_method method_name do
      self[solr_field]
    end
  end

  # rubocop:disable Naming/MethodName
  def system_of_record_ID
    self['system_of_record_ID_ssi']
  end
  # rubocop:enable Naming/MethodName

  def title_label_or_filename
    title&.first&.presence || label&.first&.presence || self['original_filename_ssi']
  end
end
