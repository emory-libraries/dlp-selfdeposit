# frozen_string_literal: true

module SelfDeposit
  class ResearchCategoriesService < ::Hyrax::QaSelectService
    def initialize
      super('research_categories')
    end
  end
end
