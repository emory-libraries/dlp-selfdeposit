# frozen_string_literal: true
module Hyrax
  class FileMetadata
    attribute :file_path, ::Valkyrie::Types::Set
    attribute :creating_os, ::Valkyrie::Types::Set
    attribute :creating_application_name, ::Valkyrie::Types::Set
    attribute :puid, ::Valkyrie::Types::Set
  end
end
