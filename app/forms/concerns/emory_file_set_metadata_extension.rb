# frozen_string_literal: true
module EmoryFileSetMetadataExtension
  extend ActiveSupport::Concern
  included do
    include Hyrax::FormFields(:emory_file_set_metadata) if respond_to?(:include_hyrax_form_fields)
    self.terms += [:pcdm_use] if respond_to?(:terms) && !terms.include?(:pcdm_use)
  end
end
