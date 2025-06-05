# frozen_string_literal: true
module HyraxHelper
  include ::BlacklightHelper
  include Hyrax::BlacklightOverride
  include Hyrax::HyraxHelperBehavior
  include NewspaperWorks::NewspaperWorksHelperBehavior

  def application_name
    ENV.fetch('APP_NAME') { super }.titleize
  end
end
