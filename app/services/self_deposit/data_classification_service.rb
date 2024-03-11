# frozen_string_literal: true

module SelfDeposit
  class DataClassificationService < ::Hyrax::QaSelectService
    def initialize
      super('data_classification')
    end
  end
end
