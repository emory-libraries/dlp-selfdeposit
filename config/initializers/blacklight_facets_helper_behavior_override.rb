# frozen_string_literal: true
# [Blacklight-overwrite-v7.37.0]
#   - #render_facet_partials: eliminates any facet group that only contains empty values.
#   - #admin_set_options: sheds and empty-valued list item.

Rails.application.config.to_prepare do
  Blacklight::FacetsHelperBehavior.module_eval do
    def render_facet_partials(fields = nil, options = {})
      deprecated_method(:render_facet_partials)

      unless fields
        Deprecation.warn(self.class, 'Calling render_facet_partials without passing the ' \
          'first argument (fields) is deprecated and will be removed in Blacklight ' \
          '8.0.0')
        fields = facet_field_names
      end

      response = options.delete(:response)
      unless response
        Deprecation.warn(self.class, 'Calling render_facet_partials without passing the ' \
          'response keyword is deprecated and will be removed in Blacklight ' \
          '8.0.0')
        response = @response
      end
      cleaned_facets_array = facets_from_request(fields, response).reject { |f| f.items.all? { |i| i.value.empty? } }

      Deprecation.silence(Blacklight::FacetsHelperBehavior) do
        Deprecation.silence(Blacklight::Facet) do
          safe_join(cleaned_facets_array.map do |display_facet|
            render_facet_limit(display_facet, options)
          end.compact, "\n")
        end
      end
    end

    def render_facet_limit_list(paginator, facet_field, wrapping_element = :li)
      facet_config ||= facet_configuration_for_field(facet_field)

      collection = paginator.items.reject { |i| i.value.empty? }.map do |item|
        facet_item_presenter(facet_config, item, facet_field)
      end

      render(facet_item_component_class(facet_config).with_collection(collection, wrapping_element:))
    end
  end
end
