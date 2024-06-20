# frozen_string_literal: true
module Hyrax
  module Dashboard
    module CollectionsControllerOverride
      # [Hyrax-override-v5.0.1] We are overwriting the `create_valkyrie_collection` method because
      # we are a new step for noid minting
      # instead of the default.
      def create_valkyrie_collection
        return after_create_errors(form_err_msg(form)) unless form.validate(collection_params)

        result =
          transactions['change_set.create_collection']
          .with_step_args(
            'change_set.set_noid_id' => {},
            'change_set.set_user_as_depositor' => { user: current_user },
            'change_set.add_to_collections' => { collection_ids: Array(params[:parent_id]) },
            'collection_resource.apply_collection_type_permissions' => { user: current_user }
          )
          .call(form)

        @collection = result.value_or { return after_create_errors(result.failure.first) }
        after_create_response
      end
    end
  end
end
