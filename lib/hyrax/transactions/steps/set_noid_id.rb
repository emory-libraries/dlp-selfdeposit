# frozen_string_literal: true
require 'noid-rails'

module Hyrax
  module Transactions
    module Steps
      ##
      # A step that sets the `#collection_type_gid` in the change set.
      #
      # @since 3.2.0
      class SetNoidId
        ##
        # @param [Hyrax::ChangeSet] change_set
        # @param alternate_ids for the collection
        def call(change_set, alternate_ids: [new_noid_id])
          return Failure[:no_alternate_ids, collection] unless
            change_set.respond_to?(:alternate_ids=)
          return Success(change_set) if
            change_set.alternate_ids.present?

          change_set.alternate_ids = alternate_ids
          Hyrax.persister.save(resource: change_set)
          Success(change_set)
        end

        private

        def new_noid_id
          "#{Noid::Rails::Service.new.mint}-emory"
        end
      end
    end
  end
end
