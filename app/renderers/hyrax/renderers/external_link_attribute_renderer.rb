# <!-- Hyrax v5.0.1 Override: added functionality so that the external link opens in a new tab. -->
# frozen_string_literal: true
module Hyrax
  module Renderers
    class ExternalLinkAttributeRenderer < AttributeRenderer
      private

      def li_value(value)
        auto_link(value, :urls, :target => "_blank", :rel => "noopener noreferrer") do |link|
          "<span class='fa fa-external-link'></span>&nbsp;#{link}"
        end
      end
    end
  end
end