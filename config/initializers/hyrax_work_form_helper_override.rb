# frozen_string_literal: true
# [Hyrax-overwrite-v5.0.1] - blocks non-admins from seeing the relationships tab.

Rails.application.config.to_prepare do
  Hyrax::WorkFormHelper.module_eval do
    ##
    # This helper allows downstream applications and engines to add/remove/reorder the tabs to be
    # rendered on the work form.
    #
    # @example with additional tabs
    #  Override this helper and ensure that it loads after Hyrax's helpers.
    #  module WorksHelper
    #    def form_tabs_for(form:)
    #      super + ["my_new_tab"]
    #    end
    #  end
    #  Add the new section partial at app/views/hyrax/base/_form_my_new_tab.html.erb
    #
    # @todo The share tab isn't included because it wasn't in guts4form.  guts4form should be
    #   cleaned up so share is treated the same as other tabs and can be included below.
    # @param form [Hyrax::Forms::WorkForm, Hyrax::Forms::ResourceForm]
    # @return [Array<String>] the list of names of tabs to be rendered in the form
    def form_tabs_for(form:)
      if form.instance_of? Hyrax::Forms::BatchUploadForm
        %w[files metadata relationships]
      elsif current_user.admin?
        %w[metadata files relationships]
      else
        %w[metadata files]
      end
    end

    ##
    # @todo this implementation hits database backends (solr) and is invoked
    #   from views. refactor to avoid
    # @return  [Array<Array<String, String, Hash>] options for the admin set drop down.
    def admin_set_options
      return [] unless current_user.admin?
      return @admin_set_options.select_options if @admin_set_options

      service = Hyrax::AdminSetService.new(controller)
      Hyrax::AdminSetOptionsPresenter.new(service).select_options
    end
  end
end
