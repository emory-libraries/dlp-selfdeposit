# frozen_string_literal: true
# [Blacklight-overwrite-v7.37.0]
#   - should_render_index_field?: need to block `all_text_tsimv` when it returns values with no string provided for query.

Rails.application.reloader.to_prepare do
  Blacklight::BlacklightHelperBehavior.module_eval do
    # @!group Document helpers
    ##
    # Determine whether to render a given field in the index view.
    #
    # @deprecated
    # @param [SolrDocument] document
    # @param [Blacklight::Configuration::Field] field_config
    # @return [Boolean]
    def should_render_index_field?(document, field_config)
      Deprecation.warn self, "should_render_index_field? is deprecated and will be removed in Blacklight 8. Use IndexPresenter#render_field? instead."

      return false if field_config.field == 'all_text_tsimv' && (request.url =~ /q=\w/).nil?
      should_render_field?(field_config, document) && document_has_value?(document, field_config)
    end
  end
end
