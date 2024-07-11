# frozen_string_literal: true
class PurlController < ApplicationController
  def redirect_to_original
    purl_object = Hyrax.custom_queries.find_by_alternate_id(alternate_ids: params[:alternate_ids])

    if purl_object.work?
      object_url = "#{request.base_url}/concern/publications/#{purl_object.id}"
      redirect_to object_url
    elsif purl_object.collection?
      object_url = "#{request.base_url}/collections/#{purl_object.id}"
      redirect_to object_url
    else
      render plain: 'Item not found', status: :not_found
    end
  rescue
    render plain: 'Item not found', status: :not_found
  end
end
