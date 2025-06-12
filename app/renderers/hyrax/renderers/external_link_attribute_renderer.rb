# [Hyrax-override-v5.1 (ec2c524)] added functionality so that the external link opens in a new tab.
# frozen_string_literal: true
module Hyrax
  module Renderers
    class ExternalLinkAttributeRenderer < AttributeRenderer
      private

      def li_value(value)
        auto_link(value, :urls, target: "_blank", rel: "noopener noreferrer") do |link|
          "&nbsp;#{link}"
        end
      end
    end
  end
end
