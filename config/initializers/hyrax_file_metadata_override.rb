# frozen_string_literal: true
# [Hyrax-override-v5.1 (ec2c524)] Adds in our own attributes.

Rails.application.config.to_prepare do
  Hyrax::FileMetadata.class_eval do
    attribute :original_checksum, ::Valkyrie::Types::Set
    attribute :file_path, ::Valkyrie::Types::Set
    attribute :creating_os, ::Valkyrie::Types::Set
    attribute :creating_application_name, ::Valkyrie::Types::Set
    attribute :puid, ::Valkyrie::Types::Set
  end
end
