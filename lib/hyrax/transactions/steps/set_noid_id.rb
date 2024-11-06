# frozen_string_literal: true
require 'noid-rails'

module Hyrax
  module Transactions
    module Steps
      ##
      # A step that sets the `#emory_persistent_id` in the change set.
      #
      # @since 3.2.0
      class SetNoidId
        include Dry::Monads[:result]

        ##
        # @param [Hyrax::ChangeSet] change_set
        # @param emory_persistent_id for the collection, file_set, publication
        def call(change_set, emory_persistent_id: new_noid_id)
          return Failure[:no_emory_persistent_id, change_set] unless
            change_set.respond_to?(:emory_persistent_id=)
          return Success(change_set) if
            change_set.emory_persistent_id.present?

          change_set.emory_persistent_id = emory_persistent_id
          Hyrax.persister.save(resource: change_set)
          Success(change_set)
        end

        private

        def new_noid_id
          "#{::Noid::Rails::Service.new.mint}-emory"
        end
      end
    end
  end
end
