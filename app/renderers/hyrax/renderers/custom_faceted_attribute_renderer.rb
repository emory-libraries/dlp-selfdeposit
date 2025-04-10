# frozen_string_literal: true
# frozen_string_literal: true
module Hyrax
  module Renderers
    class CustomFacetedAttributeRenderer < AttributeRenderer
      private

      def li_value(value)
        link_to(ERB::Util.h(value), search_path(value))
      end

      def search_path(value)
        Rails.application.routes.url_helpers.search_catalog_path("f[#{search_field}][]": value, locale: I18n.locale)
      end

      def search_field
        options.fetch(:search_field, field)
      end
    end
  end
end
