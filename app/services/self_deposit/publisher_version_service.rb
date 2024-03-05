# frozen_string_literal: true

module SelfDeposit
  class PublisherVersionService < ::Hyrax::QaSelectService
    def initialize
      super('publisher_version')
    end
  end
end
