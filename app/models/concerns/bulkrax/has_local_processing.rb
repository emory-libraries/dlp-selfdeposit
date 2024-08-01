# frozen_string_literal: true

module Bulkrax::HasLocalProcessing
  # This method is called during build_metadata
  # add any special processing here, for example to reset a metadata property
  # to add a custom property from outside of the import data
  def add_local
    # data_classification
    parsed_metadata['data_classification'] = parsed_metadata['data_classification'].blank? ? 'Public' : parsed_metadata['data_classification'].strip

    # publisher
    parsed_metadata['publisher'] = parsed_metadata['publisher'].blank? ? 'Emory University Libraries' : parsed_metadata['publisher'].strip

    process_emory_content_type
    point_file_location_to_efs
  end

  def process_emory_content_type
    authority = Qa::Authorities::Local.subauthority_for('emory_content_types')
    default_type = "http://id.loc.gov/vocabulary/resourceTypes/txt"
    pulled_type = authority.all.find { |v| v['label'] == parsed_metadata['emory_content_type']&.strip&.titleize }

    parsed_metadata['emory_content_type'] = pulled_type.present? ? pulled_type['id'] : default_type
  end

  def point_file_location_to_efs
    return if importer.zip?

    parsed_metadata['file'] = Dir.glob("/mnt/efs/current_batch/emory_#{parsed_metadata['deduplication_key']}/*")
  end
end
