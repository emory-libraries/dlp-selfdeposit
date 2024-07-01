# frozen_string_literal: true
class PurlController < ApplicationController
  def redirect_to_original
    solr_object = Hyrax.custom_queries.find_by_alternate_id(alternate_ids: params[:alternate_ids].first)
    if solr_object.has_model.present? && solr_object.has_model.first == 'Publication'
      redirect_to work_path(work)
    elsif solr_object.respond_to?(:collection_type_gid) && solr_object.collection_type_gid.present?
      redirect_to collection_path(work)
    else
      render plain: 'Item not found', status: :not_found
    end
  end
end
