# frozen_string_literal: true
class SelfDeposit::CustomQueries::FindByEmoryPersistentId < ::SelfDeposit::CustomQueries::SolrDocumentQuery
  self.queries = [:find_by_emory_persistent_id]

  def find_by_emory_persistent_id(emory_persistent_id:)
    @emory_persistent_id = emory_persistent_id
    raise ::Valkyrie::Persistence::ObjectNotFoundError unless resource
    @query_service.find_by(id: resource['id'])
  end

  def query
    "emory_persistent_id_ssi:#{@emory_persistent_id}"
  end
end
