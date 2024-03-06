# frozen_string_literal: true

module SelfDeposit
  class ContentGenresService < ::Hyrax::QaSelectService
    def initialize
      super('content_genres')
    end
  end
end
