# frozen_string_literal: true

# Generated via
#  `rails generate hyrax:work_resource Publication`
require './lib/preservation_events'
module Hyrax
  # Generated controller for Publication
  class PublicationsController < ApplicationController
    # Adds Hyrax behaviors to the controller.
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    include ::PreservationEvents
    self.curation_concern_type = ::Publication

    # Use a Valkyrie aware form service to generate Valkyrie::ChangeSet style
    # forms.
    self.work_form_service = Hyrax::FormFactory.new

    private

    ##
    # Hyrax v5.0.0 Override - inserts PreservationEvents if Publication is created successfully.
    # @return [#errors]
    # rubocop:disable Metrics/MethodLength
    def create_valkyrie_work
      @event_start = DateTime.current # record event_start timestamp
      form = build_form
      action = create_valkyrie_work_action.new(form:,
                                               transactions:,
                                               user: current_user,
                                               params:,
                                               work_attributes_key: hash_key_for_curation_concern)

      return after_create_error(form_err_msg(action.form), action.work_attributes) unless action.validate

      result = action.perform

      @curation_concern = result.value_or { return after_create_error(transaction_err_msg(result)) }
      create_preservation_event(@curation_concern, work_creation)
      create_preservation_event(@curation_concern, work_policy)
      after_create_response
    end
    # rubocop:enable Metrics/MethodLength

    # Hyrax v5.0.0 Override - inserts PreservationEvents if Publication is updated successfully.
    def update_valkyrie_work
      form = build_form
      return after_update_error(form_err_msg(form)) unless form.validate(params[hash_key_for_curation_concern])
      result =
        transactions['change_set.update_work']
        .with_step_args('work_resource.add_file_sets' => { uploaded_files:, file_set_params: params[hash_key_for_curation_concern][:file_set] },
                        'work_resource.update_work_members' => { work_members_attributes: },
                        'work_resource.save_acl' => { permissions_params: form.input_params["permissions"] })
        .call(form)
      @curation_concern = result.value_or { return after_update_error(transaction_err_msg(result)) }
      create_preservation_event(@curation_concern, work_update)
      after_update_response
    end

    def work_creation
      { 'type' => 'Validation', 'start' => @event_start, 'outcome' => 'Success', 'details' => 'Submission package validated',
        'software_version' => 'SelfDeposit v.1', 'user' => current_user.email }
    end

    def work_policy
      { 'type' => 'Policy Assignment', 'start' => @event_start, 'outcome' => 'Success', 'software_version' => 'SelfDeposit v.1',
        'details' => "Visibility/access controls assigned: #{@curation_concern.visibility}", 'user' => current_user.email }
    end

    def work_update
      { 'type' => 'Modification', 'start' => @event_start, 'outcome' => 'Success', 'details' => 'Object updated',
        'software_version' => 'SelfDeposit v.1', 'user' => current_user.email }
    end
  end
end
