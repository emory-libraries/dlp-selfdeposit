# frozen_string_literal: true
class BackgroundJobsController < ApplicationController
  with_themed_layout 'dashboard'
  def new; end

  def create
    process_non_preprocessor_jobs
  end

  private

  def process_non_preprocessor_jobs
    if params[:jobs] == 'preservation'
      generic_csv_action(params[:preservation_csv], PreservationWorkflowImporterJob)
      redirect_to new_background_job_path, notice: "Preservation Workflow Importer Job has started successfully."
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
end
