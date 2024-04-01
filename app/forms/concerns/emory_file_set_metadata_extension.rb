# app/forms/concerns/emory_file_set_metadata_extension.rb
module EmoryFileSetMetadataExtension
    extend ActiveSupport::Concern
    included do
        if respond_to?(:include_hyrax_form_fields)
          include Hyrax::FormFields(:emory_file_set_metadata)
        end
      
          
        if respond_to?(:terms)
          self.terms += [:pcdm_use] unless terms.include?(:pcdm_use)
        end
    end
end