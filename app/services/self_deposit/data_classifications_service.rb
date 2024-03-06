# frozen_string_literal: true

module SelfDeposit
  class DataClassificationsService < ::Hyrax::QaSelectService
    def initialize
      super('data_classifications')
    end
  end
end
