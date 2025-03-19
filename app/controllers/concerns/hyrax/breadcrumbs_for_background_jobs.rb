# frozen_string_literal: true
module Hyrax
  module BreadcrumbsForBackgroundJobs
    extend ActiveSupport::Concern
    include Hyrax::Breadcrumbs

    included do
      before_action :build_breadcrumbs, only: [:new]
    end

    def add_breadcrumb_for_action
      add_breadcrumb 'Background Jobs', '/background_jobs/new', mark_active_action
    end

    def mark_active_action
      { "aria-current" => "page" }
    end
  end
end
