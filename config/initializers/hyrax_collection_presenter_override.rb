# frozen_string_literal: true
# [Hyrax-override-v5.1 (ec2c524)] Adds in our desired collection terms to the show page.

Rails.application.config.to_prepare do
  Hyrax::CollectionPresenter.class_eval do
    def self.terms
      [
        :creator, :emory_persistent_id, :holding_repository, :institution, :contact_information, :keyword,
        :subject, :subject_geo, :subject_names, :rights_notes, :notes
      ]
    end

    delegate(*terms, to: :solr_document)

    def self.admin_terms
      [:emory_ark, :system_of_record_ID, :staff_notes, :internal_rights_note, :administrative_unit]
    end

    delegate(*admin_terms, to: :solr_document)

    def admin_terms_with_values
      self.class.admin_terms.select { |t| self[t].present? }
    end
  end
end
