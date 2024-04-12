# frozen_string_literal: true
# [Hyrax-overwrite-v5.0.1] - Adds in our own attributes.

Rails.application.config.to_prepare do
  Hyrax::FileMetadata.class_eval do
    attribute :original_checksum, ::Valkyrie::Types::Set
  end
end
