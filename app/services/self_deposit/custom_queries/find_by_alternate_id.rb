# frozen_string_literal: true
class SelfDeposit::CustomQueries::FindByAlternateId < ::SelfDeposit::CustomQueries::SolrDocumentQuery
  self.queries = [:find_by_alternate_id]

  def find_by_alternate_id(alternate_ids:)
    @alternate_id = alternate_ids
    raise ::Valkyrie::Persistence::ObjectNotFoundError unless resource
    @query_service.find_by(id: resource['id'])
  end

  def query
    "alternate_ids_ssim:#{@alternate_id}"
  end
end
