# frozen_string_literal: true
# Hyrax v5.0.1 override: add fileset_name and fileset_use to #create attributes

module Hyrax
  class UploadsController < ApplicationController
    load_and_authorize_resource class: Hyrax::UploadedFile

    def create
      @upload.attributes = { file: params[:file],
                             fileset_name: params[:fileset_name],
                             fileset_use: params[:fileset_use],
                             user: current_user }
      @upload.save!
    end

    def destroy
      @upload.destroy
      head :no_content
    end
  end
end
