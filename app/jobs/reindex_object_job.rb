# frozen_string_literal: true

class ReindexObjectJob < Hyrax::ApplicationJob
  def perform(id)
    object = Hyrax.query_service.find_by(id:)
    Hyrax.index_adapter.save(resource: object)
  end
end
