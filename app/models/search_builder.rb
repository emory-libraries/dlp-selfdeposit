# frozen_string_literal: true
class SearchBuilder < Blacklight::SearchBuilder
  include Blacklight::Solr::SearchBuilderBehavior
  # Add a filter query to restrict the search to documents the current user has access to
  include Hydra::AccessControlsEnforcement
  include Hyrax::SearchFilters

  self.default_processor_chain += [:highlight_search_params]

  ##
  # @example Adding a new step to the processor chain
  #   self.default_processor_chain += [:add_custom_data_to_query]
  #
  #   def add_custom_data_to_query(solr_parameters)
  #     solr_parameters[:custom] = blacklight_params[:user_value]
  #   end

  def highlight_search_params(solr_parameters = {})
    return unless solr_parameters[:q] || solr_parameters[:all_fields]
    solr_parameters[:hl] = true
    solr_parameters[:'hl.fl'] = 'all_text_tsimv'
    solr_parameters[:'hl.fragsize'] = 100
    solr_parameters[:'hl.snippets'] = 5
  end
end
