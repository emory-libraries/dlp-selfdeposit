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
  end

  def process_emory_content_type
    authority = Qa::Authorities::Local.subauthority_for('emory_content_types')
    default_type = "http://id.loc.gov/vocabulary/resourceTypes/txt"
    pulled_type = authority.all.find { |v| v['label'] == parsed_metadata['emory_content_type']&.strip&.titleize }

    parsed_metadata['emory_content_type'] = pulled_type.fetch('id', default_type)
  end
end
