# frozen_string_literal: true
require './lib/preservation_events'

module SelfDeposit
  module Workflow
    module RegisterApprovalPreservationEvent
      extend ::PreservationEvents

      ##
      # This is a function for the emory_mediated_deposit workflow, creating a
      #   PreservationEvent chronicling the approval of the Publication by an
      #   appointed approver.
      #
      # @param target: Publication instance
      #
      # @return Publication Instance
      def self.call(target:, user:, **)
        approval_event = {
          'type' => 'Metadata modification',
          'start' => DateTime.current,
          'outcome' => 'Success',
          'details' => 'Deposit reviewed and approved',
          'software_version' => 'SelfDeposit v.1',
          'user' => user.email
        }
        model = target.try(:model) || target # get the model if target is a ChangeSet

        create_preservation_event(model, approval_event)
      end
    end
  end
end
