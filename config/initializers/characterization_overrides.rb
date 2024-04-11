# frozen_string_literal: true
Rails.application.config.to_prepare do
  Hyrax::FileSet::Characterization.prepend Hyrax::FileSet::CharacterizationExtension
end
