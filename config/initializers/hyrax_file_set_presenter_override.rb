# frozen_string_literal: true
# [Hyrax-overwrite-v5.0.1] - Adds in our charaterization terms to show on the fileset show page.

Rails.application.config.to_prepare do
  Hyrax::FileSetPresenter.class_eval do
    def self.characterization_terms
      [
        :byte_order, :compression, :height, :width, :color_space, :profile_name, :profile_version,
        :orientation, :color_map, :image_producer, :capture_device, :scanning_software, :gps_timestamp,
        :latitude, :longitude, :file_format, :file_title, :page_count, :duration, :sample_rate, :format_label,
        :file_size, :filename, :well_formed, :last_modified, :mime_type, :alpha_channels, :file_path,
        :creating_application_name, :creating_os, :persistent_unique_identification, :original_checksum
      ]
    end

    delegate(*characterization_terms, to: :solr_document)

    # The title of the webpage that shows this FileSet.
    def page_title
      "File Set: #{id}"
    end
  end
end
