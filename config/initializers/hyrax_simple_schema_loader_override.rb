# frozen_string_literal: true
# [Hyrax-overwrite-v5.1.0] -set collection type to be ordered when `ordered: true` is set in the configuration

Rails.application.config.to_prepare do
  Hyrax::SimpleSchemaLoader::AttributeDefinition.class_eval do
    # @return [Dry::Types::Type]
    def type
      collection_type = if config['multiple']
                          Valkyrie::Types::Array.constructor { |v| Array(v).select(&:present?) }
                        else
                          Hyrax::SimpleSchemaLoader::AttributeDefinition::Identity
                        end

      config['ordered'] ? collection_type.of(type_for(config['type'])).meta(ordered: true) : collection_type.of(type_for(config['type']))
    end
  end
end
