# frozen_string_literal: true
class BackgroundJobsController < ApplicationController
  include Hyrax::BreadcrumbsForBackgroundJobs
  with_themed_layout 'dashboard'
  before_action :authenticate_user!

  def new; end

  def create
    process_non_preprocessor_jobs
  end

  private

  def process_non_preprocessor_jobs
    if params[:jobs] == 'preservation'
      generic_csv_action(params[:preservation_csv], PreservationWorkflowImporterJob)
      redirect_to new_background_job_path, notice: "Preservation Workflow Importer Job has started successfully."
    elsif params[:jobs] == 'publications_to_collection'
      link_unlinked_publications_to_collection
    elsif params[:jobs] == 'preservation_event_remediation'
      RemediateObjectsLackingPreservationEventsJob.perform_later
      redirect_to new_background_job_path, notice: "PreservationEvent Remediation Job has started successfully."
    else
      reindex_objects_action
      redirect_to new_background_job_path, notice: "Reindex Files Job has started successfully."
    end
  end

  def reindex_objects_action
    CSV.foreach(params[:reindex_csv].path, headers: true) do |row|
      r = row.to_h
      ReindexObjectJob.perform_later(r['id'])
    end
  end

  def generic_csv_action(csv_param, job_class)
    name = csv_param.original_filename
    path = Rails.root.join('tmp', name)
    File.open(path, "w+") { |f| f.write(csv_param.read) }
    job_class.perform_later(path.to_s)
  end

  def link_unlinked_publications_to_collection
    unlinked_publication_ids = Hyrax.query_service.custom_queries.find_all_publication_ids_unlinked_to_collection
    collection_id = params[:collection_id]

    if unlinked_publication_ids.present?
      unlinked_publication_ids.each_slice(1000) do |batch_array|
        BatchAddPublicationsToCollectionJob.perform_later(collection_id:, member_ids_array: batch_array, user: current_user)
      end
      redirect_to new_background_job_path, notice: publication_text(publication_count: unlinked_publication_ids.count, collection_id:)
    else
      redirect_to new_background_job_path, notice: "No Publications unlinked to a Collection were found."
    end
  end

  def publication_text(publication_count:, collection_id:)
    publication_count_text(publication_count:) + collection_id_text(collection_id:) + " Background Jobs will process these in batches of 1000. Check Sidekiq for progress."
  end

  def publication_count_text(publication_count:)
    "A total of #{publication_count} Publication(s) lacking Collection association were found."
  end

  def collection_id_text(collection_id:)
    if collection_id.present?
      " The Collection ID of #{collection_id} was provided to be associated to the Publication(s)."
    else
      " No Collection ID was provided. The Background Jobs will attempt to locate the Collection ID from internal settings."
    end
  end
end
