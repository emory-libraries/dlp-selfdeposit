# frozen_string_literal: true
# Hyrax v5.0.1 override: add fileset_name and fileset_use to #create attributes

module Hyrax
  class UploadsController < ApplicationController
    load_and_authorize_resource class: Hyrax::UploadedFile

    def create
      upload_attributes = {}
      upload_attributes[:file] = params[:files].first
      upload_attributes[:fileset_name] = params[:fileset_name] if params[:fileset_name].present?
      upload_attributes[:fileset_use] = params[:fileset_use] if params[:fileset_use].present?
      upload_attributes[:user] = current_user
      @upload.attributes = upload_attributes
      @upload.save!
    end

    def destroy
      @upload.destroy
      head :no_content
    end
  end
end
