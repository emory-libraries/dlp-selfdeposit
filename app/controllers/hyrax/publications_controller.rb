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

    # Hyrax v5.0.1 Override - L#26 defaults visibility in the form to Public.
    def new
      @admin_set_options = available_admin_sets
      # TODO: move these lines to the work form builder in Hyrax
      curation_concern.depositor = current_user.user_key
      curation_concern.admin_set_id = admin_set_id_for_new
      build_form
      @form.visibility = 'open'
    end

    def add_custom_facet_params(form)
      add_custom_date_issued_facet(form)
      add_custom_creator_facet(form)
    end

    def add_custom_date_issued_facet(form)
      form.date_issued_year = params[:publication][:date_issued]&.split('-')&.first
    end

    def add_custom_creator_facet(form)
      form.creator_last_first = params[:publication][:creator]&.map do |v|
        return nil if v.nil?
        nv = v&.split(',')&.first(2)&.reverse
        nv = nv&.map { |i| i&.strip }
        nv&.join(', ')
      end
    end

    private

    ##
    # Hyrax v5.0.1 Override - inserts PreservationEvents if Publication is created successfully.
    # @return [#errors]
    # rubocop:disable Metrics/MethodLength
    def create_valkyrie_work
      event_start = DateTime.current # record event_start timestamp
      form = build_form
      assign_defaults_for_non_admins(form)
      add_custom_facet_params(form)
      action = create_valkyrie_work_action.new(form:,
                                               transactions:,
                                               user: current_user,
                                               params:,
                                               work_attributes_key: hash_key_for_curation_concern)

      return after_create_error(form_err_msg(action.form), action.work_attributes) unless action.validate

      result = action.perform

      @curation_concern = result.value_or { return after_create_error(transaction_err_msg(result)) }
      create_preservation_event(@curation_concern, work_creation(event_start:, user_email: current_user.email))
      create_preservation_event(
        @curation_concern,
        work_policy(event_start:, visibility: @curation_concern.visibility, user_email: current_user.email)
      )
      after_create_response
    end
    # rubocop:enable Metrics/MethodLength

    # Hyrax v5.0.1 Override - inserts PreservationEvents if Publication is updated successfully.
    def update_valkyrie_work
      event_start = DateTime.current
      form = build_form
      add_custom_facet_params(form)
      return after_update_error(form_err_msg(form)) unless form.validate(sanitized_params)
      result =
        transactions['change_set.update_work']
        .with_step_args('work_resource.add_file_sets' => { uploaded_files:, file_set_params: params[hash_key_for_curation_concern][:file_set] },
                        'work_resource.update_work_members' => { work_members_attributes: },
                        'work_resource.save_acl' => { permissions_params: form.input_params["permissions"] })
        .call(form)
      @curation_concern = result.value_or { return after_update_error(transaction_err_msg(result)) }
      create_preservation_event(@curation_concern, work_update(event_start:, user_email: current_user.email))
      after_update_response
    end

    # Hyrax 5.0.1 override
    # Sometimes the order of permissions is not the same between saved permissions and new permissions for Valkyrie
    # I am replacing array comparison (which relies on order) with comparing array sizes and checking for existence of elements in both arrays
    def permissions_changed?
      case curation_concern
      when ActiveFedora::Base
        @saved_permissions != curation_concern.permissions.map(&:to_hash)
      else
        new_permissions = Hyrax::AccessControl.for(resource: curation_concern).permissions
        saved_permissions_set = @saved_permissions.to_set
        new_permissions.size != @saved_permissions.size || new_permissions.any? { |e| !saved_permissions_set.include? e }
      end
    end

    # Hyrax v5.0.1 Override - adds our respond_to_ris custom method.
    def additional_response_formats(format)
      respond_to_ris(format)
      respond_to_endnote(format)
      respond_to_ttl(format)
      respond_to_jsonld(format)
      respond_to_nt(format)
    end

    def assign_defaults_for_non_admins(form)
      return if current_user.admin?

      form.admin_set_id = ENV.fetch('OPENEMORY_WORKFLOW_ADMIN_SET_ID', Hyrax::AdminSetCreateService.find_or_create_default_admin_set.id.to_s)
      form.member_of_collection_ids = [ENV.fetch('OPENEMORY_COLLECTION_ID', nil)]
    end

    def sanitized_params
      params[hash_key_for_curation_concern].each { |k, v| params[hash_key_for_curation_concern][k] = v.reject(&:blank?) if v.is_a?(Array) }
    end

    def respond_to_ris(format)
      format.ris do
        send_data(presenter.solr_document.export_as_ris(request.base_url),
                  type: "application/x-research-info-systems",
                  filename: presenter.solr_document.ris_filename)
      end
    end
  end
end
