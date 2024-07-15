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

    def pres_events
      solr_document&.preservation_events&.map { |pe| JSON.parse(pe) }&.sort_by { |e| e["event_start"] }&.reverse
    end
  end

  # Valkyrie::Persistence::Fedora::QueryService.class_eval do
  #   def find_parents(resource:)
  #     debugger
  #     content = content_with_inbound(id: resource.id)
  #     parent_ids = content.graph.query([nil, RDF::Vocab::ORE.proxyFor, nil]).map(&:subject).map { |x| x.to_s.gsub(/#.*/, '') }.map { |x| adapter.uri_to_id(x) }
  #     parent_ids.uniq!
  #     parent_ids.lazy.map do |id|
  #       find_by(id: id)
  #     end
  #   end
  # end
end


